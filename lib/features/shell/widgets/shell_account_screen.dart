import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Account tab shared by the Coach "More" tab and the Trainee "Profile" tab.
///
/// A placeholder for the real profile / settings screens, but the logout action
/// is fully wired to [SessionCubit]: after `logout()` the app-level session
/// emits `Unauthenticated`, which the [PostLoginRouter] listens for and routes
/// back to the login screen.
///
// TODO(Phase 3): replace the profile/settings placeholder with the real
// account & settings screens (keep the logout affordance).
class ShellAccountScreen extends StatelessWidget {
  /// snake_case translation key used for the section title.
  final String titleKey;

  const ShellAccountScreen({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>().session;
    final email = session?.email ?? '';

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: titleKey.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identity header
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
                    child: Icon(
                      Icons.person_outline,
                      color: AppDesignSystem.primaryColor,
                      size: AppDesignSystem.iconSizeLG.sp,
                    ),
                  ),
                  SizedBox(width: AppDesignSystem.spacingMD.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.userName ?? '',
                          style: AppDesignSystem.h5.copyWith(
                            color: AppDesignSystem.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email.isNotEmpty) ...[
                          SizedBox(height: AppDesignSystem.spacing2XS.h),
                          Text(
                            email,
                            style: AppDesignSystem.bodySmall.copyWith(
                              color: AppDesignSystem.neutral500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),

            // Profile / settings placeholder note
            AppCard(
              variant: AppCardVariant.outlined,
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: AppDesignSystem.neutral400,
                    size: AppDesignSystem.iconSizeMD.sp,
                  ),
                  SizedBox(width: AppDesignSystem.spacingMD.w),
                  Expanded(
                    child: Text(
                      'coming_soon_subtitle'.tr(),
                      style: AppDesignSystem.bodyMedium.copyWith(
                        color: AppDesignSystem.neutral500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXL.h),

            // Logout — fully wired to the app-level session.
            AppButton(
              text: 'logout'.tr(),
              icon: Icons.logout,
              variant: AppButtonVariant.danger,
              fullWidth: true,
              onPressed: () => context.read<SessionCubit>().logout(),
            ),
          ],
        ),
      ),
    );
  }
}
