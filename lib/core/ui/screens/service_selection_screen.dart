import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coachappmobile/core/constant/app_colors/app_colors.dart';
import 'package:coachappmobile/core/constant/text_styles/app_text_style.dart';
import 'package:coachappmobile/core/constant/text_styles/font_size.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedService;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectService(String service) {
    setState(() {
      _selectedService = service;
    });

    // Add haptic feedback or any navigation logic here
    Future.delayed(const Duration(milliseconds: 300), () {
      // Navigation logic based on selected service
      // Example: Navigation.push(const NextScreen());
      if (!mounted) return;

      String safeTranslate(String keyOrValue) {
        // treat keys as ASCII + underscores only (translation keys)
        final isKey = RegExp(r'^[A-Za-z0-9_]+$').hasMatch(keyOrValue);
        return isKey ? keyOrValue.tr() : keyOrValue;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${"selected".tr()}: ${safeTranslate(service)}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FE),
              const Color(0xFFFFF8F0),
              const Color(0xFFFFFBF5),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        "select_service_type".tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.getBoldStyle(
                          fontSize: AppFontSize.size_22,
                          color: AppColors.neutral900,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "choose_delivery_option".tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.getRegularStyle(
                          fontSize: AppFontSize.size_14,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),

                // Service Cards Section
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),

                            // Express Service Card
                            _buildServiceCard(
                              service: 'express',
                              title: 'express_delivery'.tr(),
                              subtitle: 'express_delivery_desc'.tr(),
                              icon: Icons.flash_on_rounded,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              features: [
                                'fast_delivery'.tr(),
                                'same_day_service'.tr(),
                                'priority_handling'.tr(),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Freight Service Card
                            _buildServiceCard(
                              service: 'freight',
                              title: 'freight_delivery'.tr(),
                              subtitle: 'freight_delivery_desc'.tr(),
                              icon: Icons.local_shipping_rounded,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.secoundPrimary,
                                  AppColors.secoundPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                ],
                              ),
                              features: [
                                'bulk_shipments'.tr(),
                                'cost_effective'.tr(),
                                'large_parcels'.tr(),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Footer
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 16.h,
                              ),
                              child: Text(
                                "need_help_contact_support".tr(),
                                textAlign: TextAlign.center,
                                style: AppTextStyle.getRegularStyle(
                                  fontSize: AppFontSize.size_12,
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String service,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required List<String> features,
  }) {
    final isSelected = _selectedService == service;

    return GestureDetector(
      onTap: () => _selectService(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (service == 'express'
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.secoundPrimary.withValues(alpha: 0.25))
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 16 : 8,
              spreadRadius: 0,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => _selectService(service),
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon Container
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : (service == 'express'
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : AppColors.secoundPrimary.withValues(
                                        alpha: 0.08,
                                      )),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          icon,
                          size: 28.sp,
                          color: isSelected
                              ? Colors.white
                              : (service == 'express'
                                    ? AppColors.primary
                                    : AppColors.secoundPrimary),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Title and Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyle.getBoldStyle(
                                fontSize: AppFontSize.size_18,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.neutral900,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              subtitle,
                              style: AppTextStyle.getRegularStyle(
                                fontSize: AppFontSize.size_13,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection Indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : AppColors.neutral300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: service == 'express'
                                    ? AppColors.primary
                                    : AppColors.secoundPrimary,
                              )
                            : null,
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Features List
                  ...features.map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16.sp,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : (service == 'express'
                                      ? AppColors.primary
                                      : AppColors.secoundPrimary),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyle.getRegularStyle(
                                fontSize: AppFontSize.size_13,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.neutral700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
