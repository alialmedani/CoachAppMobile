import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/boilerplate/pagination/models/get_list_request.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/ascent_monogram.dart';
import 'package:coachappmobile/core/ui/widgets/apex/duotone_hero.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/templates/templates_screen.dart';
import 'package:coachappmobile/features/coach/trainees/cubit/trainee_cubit.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:coachappmobile/features/coach/trainees/screen/trainee_detail_screen.dart';
import 'package:coachappmobile/features/coach/trainees/screen/widgets/trainee_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The coach's home — the Apex **Command Center**: an identity hero, a live
/// "Your Athletes" preview rail (the first few of the real, paged roster), and a
/// chamfered control deck into every authoring area. Honest by design: there is
/// no roster-wide backend aggregate, so this is a launchpad + roster pulse, not a
/// fabricated KPI wall. Permission-gated exactly as the previous quick-access
/// grid; switches shell tabs via [onOpenTab] or pushes the self-providing
/// [TemplatesScreen].
class CoachDashboardScreen extends StatefulWidget {
  /// Switch the enclosing shell to the tab with this label key.
  final void Function(String labelKey)? onOpenTab;

  const CoachDashboardScreen({super.key, this.onOpenTab});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  GetModelCubit? _preview;

  Future<void> _openDetail(TraineeCubit cubit, TraineeModel trainee) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TraineeDetailScreen(traineeId: trainee.id ?? ''),
        ),
      ),
    );
    if (changed == true) _preview?.getModel();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final cubit = context.read<TraineeCubit>();
    final userName = session.session?.userName;

    final tiles = <Widget>[
      if (session.can(CoachPermissions.trainees))
        _DeckTile(
          icon: AppIcons.roster,
          label: 'trainees'.tr(),
          subtitle: 'roster_and_profiles'.tr(),
          onTap: () => widget.onOpenTab?.call('tab_trainees'),
        ),
      if (session.can(CoachPermissions.exercises) ||
          session.can(CoachPermissions.foods))
        _DeckTile(
          icon: AppIcons.library,
          label: 'library'.tr(),
          subtitle: 'exercises_and_foods'.tr(),
          onTap: () => widget.onOpenTab?.call('tab_library'),
        ),
      if (session.can(CoachPermissions.workoutPlans) ||
          session.can(CoachPermissions.nutritionPlans))
        _DeckTile(
          icon: AppIcons.plans,
          label: 'plans'.tr(),
          subtitle: 'workout_and_nutrition'.tr(),
          onTap: () => widget.onOpenTab?.call('tab_plans'),
        ),
      if (session.can(CoachPermissions.workoutPlanTemplates) ||
          session.can(CoachPermissions.nutritionPlanTemplates))
        _DeckTile(
          icon: AppIcons.plans,
          label: 'templates'.tr(),
          subtitle: 'reusable_programs'.tr(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TemplatesScreen()),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'dashboard'.tr()),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppDesignSystem.spacingMD.w,
          AppDesignSystem.spacingMD.h,
          AppDesignSystem.spacingMD.w,
          AppDesignSystem.spacing4XL.h,
        ),
        children: [
          _Hero(userName: userName),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          if (session.can(CoachPermissions.trainees)) ...[
            _SectionRow(
              title: 'your_athletes'.tr(),
              actionLabel: 'view_all'.tr(),
              onAction: () => widget.onOpenTab?.call('tab_trainees'),
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            GetModel<List<TraineeModel>>(
              onCubitCreated: (c) => _preview = c,
              useCaseCallBack: () =>
                  cubit.fetchTraineeList(GetListRequest(skip: 0, take: 6)),
              loadingWidget: SizedBox(
                height: 140.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
              modelBuilder: (list) => list.isEmpty
                  ? _EmptyRoster(onAdd: () => widget.onOpenTab?.call('tab_trainees'))
                  : Column(
                      children: [
                        for (final t in list)
                          TraineeCard(
                            trainee: t,
                            onTap: () => _openDetail(cubit, t),
                          ),
                      ],
                    ),
            ),
            SizedBox(height: AppDesignSystem.spacingLG.h),
          ],
          if (tiles.isNotEmpty) ...[
            Text(
              'build_and_manage'.tr(),
              style: AppDesignSystem.h6
                  .copyWith(color: AppDesignSystem.textPrimary),
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            _DeckGrid(tiles: tiles),
          ],
        ],
      ),
    );
  }
}

/// Identity hero — the monogram, a welcome overline, and the coach's name.
/// Deliberately gauge-free (no honest roster-wide number exists to gauge).
class _Hero extends StatelessWidget {
  final String? userName;
  const _Hero({this.userName});

  @override
  Widget build(BuildContext context) {
    final hasName = (userName ?? '').isNotEmpty;
    return DuotoneHero(
      ghostText: 'dashboard'.tr(),
      child: Row(
        children: [
          AscentMonogram(size: 46.w, background: AppDesignSystem.surfaceSunken),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back'.tr().toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSizeSM.sp,
                    fontWeight: AppDesignSystem.bold,
                    letterSpacing: 1.5,
                    color: AppDesignSystem.primaryStrong,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  hasName ? userName! : 'dashboard'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h3.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.extraBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A section header with a trailing text action ("View all ›").
class _SectionRow extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionRow({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppDesignSystem.h6
                .copyWith(color: AppDesignSystem.textPrimary),
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacingXS.w,
              vertical: AppDesignSystem.spacing2XS.h,
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.primaryStrong,
                    fontWeight: AppDesignSystem.bold,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: AppDesignSystem.iconSizeSM.sp,
                    color: AppDesignSystem.primaryStrong),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyRoster({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onAdd,
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
              shape: const ChamferBorder(cut: 10),
            ),
            child: AppIcon(AppIcons.roster,
                size: AppDesignSystem.iconSizeSM,
                color: AppDesignSystem.primaryStrong),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Text(
              'no_trainees'.tr(),
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.textPrimary,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
          ),
          Icon(Icons.chevron_right,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.textFaint),
        ],
      ),
    );
  }
}

/// Lays a list of [_DeckTile]s out as a 2-up chamfered grid with equal-height
/// rows.
class _DeckGrid extends StatelessWidget {
  final List<Widget> tiles;
  const _DeckGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  SizedBox(width: AppDesignSystem.spacingSM.w),
                  if (i + 1 < tiles.length)
                    Expanded(child: tiles[i + 1])
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A chamfered control-deck tile: bespoke icon chip + label + subtitle.
class _DeckTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DeckTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppDesignSystem.surfaceRaised,
      shape: ChamferBorder(
        cut: 14,
        side: BorderSide(color: AppDesignSystem.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
                  shape: const ChamferBorder(cut: 10),
                ),
                child: AppIcon(icon,
                    size: AppDesignSystem.iconSizeSM,
                    color: AppDesignSystem.primaryStrong),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.labelLarge.copyWith(
                  color: AppDesignSystem.textPrimary,
                  fontWeight: AppDesignSystem.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.bodySmall
                    .copyWith(color: AppDesignSystem.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
