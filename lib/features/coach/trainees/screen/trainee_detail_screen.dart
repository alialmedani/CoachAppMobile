import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/coach_dashboard_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/coach_log_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/notes_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/cubit/progress_cubit.dart';
import 'package:coachappmobile/features/coach/tracking/screen/coach_dashboard_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/coach_logs_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/notes_screen.dart';
import 'package:coachappmobile/features/coach/tracking/screen/progress_screen.dart';

import '../cubit/trainee_cubit.dart';
import '../data/model/trainee_model.dart';
import 'edit_trainee_screen.dart';
import 'widgets/reset_password_sheet.dart';

/// Full trainee profile with coach actions: edit, reset password, delete.
class TraineeDetailScreen extends StatefulWidget {
  final String traineeId;

  const TraineeDetailScreen({super.key, required this.traineeId});

  @override
  State<TraineeDetailScreen> createState() => _TraineeDetailScreenState();
}

class _TraineeDetailScreenState extends State<TraineeDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after an edit/reset/delete;
    // a plain implicit pop returns null and would leave the list stale.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'trainee_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<TraineeModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchTraineeById(widget.traineeId),
          modelBuilder: (trainee) => _Body(
            trainee: trainee,
            onEdit: () => _edit(cubit, trainee),
            onResetPassword: () => showResetPasswordSheet(
              context,
              cubit: cubit,
              traineeId: trainee.id ?? widget.traineeId,
              traineeName: trainee.fullName,
            ),
            onDelete: () => _confirmDelete(cubit, trainee),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(TraineeCubit cubit, TraineeModel trainee) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: EditTraineeScreen(trainee: trainee),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _confirmDelete(TraineeCubit cubit, TraineeModel trainee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('deactivate_trainee'.tr()),
        content: Text('deactivate_trainee_confirm'.tr(args: [trainee.fullName])),
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
            child: Text('deactivate'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await cubit.deleteTrainee(trainee.id ?? widget.traineeId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trainee_deactivated'.tr()),
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
}

class _Body extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  const _Body({
    required this.trainee,
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(trainee: trainee),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          _Section(
            title: 'coaching_profile'.tr(),
            rows: [
              _InfoRow(
                icon: Icons.flag_outlined,
                label: 'training_goal'.tr(),
                value: trainee.goal.labelKey.tr(),
              ),
              _InfoRow(
                icon: Icons.wc_outlined,
                label: 'gender'.tr(),
                value: trainee.gender.labelKey.tr(),
              ),
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'birth_date'.tr(),
                value: _formatDate(trainee.birthDate),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _Section(
            title: 'measurements'.tr(),
            rows: [
              _InfoRow(
                icon: Icons.height_outlined,
                label: 'height_cm'.tr(),
                value: _formatNum(trainee.heightCm, 'unit_cm'.tr()),
              ),
              _InfoRow(
                icon: Icons.monitor_weight_outlined,
                label: 'start_weight_kg'.tr(),
                value: _formatNum(trainee.startWeightKg, 'unit_kg'.tr()),
              ),
              _InfoRow(
                icon: Icons.flag_circle_outlined,
                label: 'target_weight_kg'.tr(),
                value: _formatNum(trainee.targetWeightKg, 'unit_kg'.tr()),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          _Section(
            title: 'contact_information'.tr(),
            rows: [
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'email'.tr(),
                value: trainee.email ?? '—',
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'phone'.tr(),
                value: trainee.phoneNumber ?? '—',
              ),
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'member_since'.tr(),
                value: _formatDate(trainee.creationTime),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          _TrackingSection(trainee: trainee),
          SizedBox(height: AppDesignSystem.spacingXL.h),
          AppButton(
            text: 'edit_profile'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: onEdit,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          AppButton(
            text: 'reset_password'.tr(),
            icon: Icons.lock_reset_outlined,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: onResetPassword,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          AppButton(
            text: 'deactivate_trainee'.tr(),
            icon: Icons.person_off_outlined,
            variant: AppButtonVariant.danger,
            fullWidth: true,
            onPressed: onDelete,
          ),
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _formatNum(double? v, String unit) {
    if (v == null) return '—';
    final n = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return '$n $unit';
  }
}

/// Permission-gated entry points into this trainee's tracking surface
/// (dashboard, logs, progress, notes). Each opens a screen scoped to the
/// trainee with its own feature cubit.
class _TrackingSection extends StatelessWidget {
  final TraineeModel trainee;

  const _TrackingSection({required this.trainee});

  void _open(BuildContext context, Widget child) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => child));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final id = trainee.id ?? '';
    final name = trainee.fullName;
    final tiles = <Widget>[];

    if (session.can(CoachPermissions.tracking)) {
      tiles.add(
        _TrackingTile(
          icon: Icons.dashboard_outlined,
          label: 'coach_dashboard'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<CoachDashboardCubit>(),
              child: CoachDashboardScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
      tiles.add(
        _TrackingTile(
          icon: Icons.receipt_long_outlined,
          label: 'logs'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<CoachLogCubit>(),
              child: CoachLogsScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }
    if (session.can(CoachPermissions.progress)) {
      tiles.add(
        _TrackingTile(
          icon: Icons.insights_outlined,
          label: 'progress'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<ProgressCubit>(),
              child: ProgressScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }
    if (session.can(CoachPermissions.notes)) {
      tiles.add(
        _TrackingTile(
          icon: Icons.sticky_note_2_outlined,
          label: 'notes'.tr(),
          onTap: () => _open(
            context,
            BlocProvider(
              create: (_) => getIt<NotesCubit>(),
              child: NotesScreen(traineeId: id, traineeName: name),
            ),
          ),
        ),
      );
    }

    if (tiles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppDesignSystem.spacingXS.w,
            bottom: AppDesignSystem.spacingXS.h,
          ),
          child: Text(
            'tracking'.tr(),
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
        ),
        ...tiles,
      ],
    );
  }
}

class _TrackingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TrackingTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primarySurface,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              icon,
              color: AppDesignSystem.primaryDark,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Text(
              label,
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.neutral900,
                fontWeight: AppDesignSystem.medium,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TraineeModel trainee;

  const _Header({required this.trainee});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppDesignSystem.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              trainee.initial,
              style: AppDesignSystem.h2.copyWith(
                color: AppDesignSystem.primaryDark,
              ),
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Text(
            trainee.fullName,
            textAlign: TextAlign.center,
            style: AppDesignSystem.h4.copyWith(
              color: AppDesignSystem.neutral900,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacing2XS.h),
          Text(
            '@${trainee.userName ?? ''}',
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          AppBadge(
            text: (trainee.isActive ? 'active' : 'inactive').tr(),
            variant: trainee.isActive
                ? AppBadgeVariant.success
                : AppBadgeVariant.neutral,
            dot: true,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppDesignSystem.spacingXS.w,
            bottom: AppDesignSystem.spacingXS.h,
          ),
          child: Text(
            title,
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
        ),
        AppCard(child: Column(children: rows)),
      ],
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDesignSystem.iconSizeSM.sp,
            color: AppDesignSystem.neutral400,
          ),
          SizedBox(width: AppDesignSystem.spacingSM.w),
          Text(
            label,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutral900,
                fontWeight: AppDesignSystem.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
