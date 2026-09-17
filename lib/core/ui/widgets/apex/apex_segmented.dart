import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';

/// The Apex segmented control — a sunken pill track with the selected segment
/// lifted onto a raised tile and its label in Volt. Reused for the trainees
/// status filter, the coach dashboard date range, and the logs workout/nutrition
/// toggle, so those surfaces read as one system. Labels are already localized.
class ApexSegmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const ApexSegmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceSunken,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: _Seg(
                label: labels[i],
                selected: i == index,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Seg({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
      child: AnimatedContainer(
        duration: AppDesignSystem.durationFast,
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
        decoration: BoxDecoration(
          color: selected ? AppDesignSystem.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
          boxShadow: selected ? AppDesignSystem.shadowSM : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppDesignSystem.fontFamily,
            fontSize: AppDesignSystem.fontSizeSM.sp,
            fontWeight: AppDesignSystem.bold,
            letterSpacing: 0.2,
            color: selected
                ? AppDesignSystem.primaryStrong
                : AppDesignSystem.textMuted,
          ),
        ),
      ),
    );
  }
}
