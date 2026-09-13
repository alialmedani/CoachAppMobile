import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/Navigation/navigation.dart';
import 'package:coachappmobile/features/shell/coach_shell.dart';
import 'package:coachappmobile/features/shell/trainee_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/session_cubit.dart';
import 'login_screen.dart';

/// Role gate shown after login (and as the splash `home:` when a token is
/// cached). It restores the session on a cold start, then routes to the Coach
/// or Trainee shell. Accounts with neither role fall back to a placeholder that
/// still offers logout.
class PostLoginRouter extends StatefulWidget {
  const PostLoginRouter({super.key});

  @override
  State<PostLoginRouter> createState() => _PostLoginRouterState();
}

class _PostLoginRouterState extends State<PostLoginRouter> {
  @override
  void initState() {
    super.initState();
    // Cold start: if we arrived here from the splash with a cached token, the
    // session still needs to be bootstrapped. (Skipped when we came straight
    // from a fresh login, which already left us Authenticated.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<SessionCubit>();
      if (cubit.state is! Authenticated) {
        cubit.restoreSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigation.pushAndRemoveUntil(const LoginScreen());
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          final cubit = context.read<SessionCubit>();
          if (cubit.isCoach) {
            return const CoachShell();
          }
          if (cubit.isTrainee) {
            return const TraineeShell();
          }
          return _RoleHomePlaceholder(
            title: 'no_role_assigned'.tr(),
            subtitle: state.session.userName ?? '',
            icon: Icons.help_outline,
          );
        }

        // SessionInitial / Authenticating (and the brief window before the
        // Unauthenticated listener navigates away).
        return const Scaffold(body: AppLoadingIndicator());
      },
    );
  }
}

/// Minimal placeholder home for a signed-in role. Phase 2 swaps this out for
/// the real Coach / Trainee shells.
class _RoleHomePlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _RoleHomePlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: title,
        actions: [
          IconButton(
            tooltip: 'logout'.tr(),
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<SessionCubit>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.spacingXL.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppDesignSystem.spacingLG.r),
                decoration: BoxDecoration(
                  color: AppDesignSystem.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppDesignSystem.iconSizeXL.sp,
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppDesignSystem.h4.copyWith(
                  color: AppDesignSystem.neutral900,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: AppDesignSystem.spacingXS.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
