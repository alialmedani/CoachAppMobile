import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_enums.dart';
import 'muscle_atlas_mapping.dart';

/// Interactive front/back muscle map (powered by `flutter_body_atlas`).
///
/// Highlights the muscles of [selected] in the design-system volt color. When
/// [onSelected] is provided the map becomes a PICKER: tapping a muscle reports
/// the tapped muscle mapped back onto our [MuscleGroup]. When it's null the map
/// is read-only (display).
///
/// The atlas artwork is by Ryan Graves (CC BY 4.0) and the package is BSD-3 —
/// an attribution caption is rendered below the figure to satisfy the licenses.
class MuscleAtlas extends StatefulWidget {
  final MuscleGroup selected;
  final ValueChanged<MuscleGroup>? onSelected;
  final double? height;

  const MuscleAtlas({
    super.key,
    required this.selected,
    this.onSelected,
    this.height,
  });

  @override
  State<MuscleAtlas> createState() => _MuscleAtlasState();
}

class _MuscleAtlasState extends State<MuscleAtlas> {
  late atlas.AtlasAsset _view;

  bool get _interactive => widget.onSelected != null;

  @override
  void initState() {
    super.initState();
    _view = MuscleAtlasMapping.defaultView(widget.selected);
  }

  @override
  void didUpdateWidget(covariant MuscleAtlas old) {
    super.didUpdateWidget(old);
    // When the selection changes (coach taps a new muscle) swing to the layer
    // where that group reads best, so the highlight is always visible.
    if (old.selected != widget.selected) {
      _view = MuscleAtlasMapping.defaultView(widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorMapping = <atlas.MuscleInfo, Color?>{
      for (final m in MuscleAtlasMapping.musclesFor(widget.selected))
        m: AppDesignSystem.primaryStrong,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ViewToggle(view: _view, onChanged: (v) => setState(() => _view = v)),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        SizedBox(
          height: widget.height ?? 320.h,
          child: atlas.BodyAtlasView<atlas.MuscleInfo>(
            view: _view,
            resolver: const atlas.MuscleResolver(),
            colorMapping: colorMapping,
            onTapElement: _interactive
                ? (info) =>
                      widget.onSelected!(MuscleAtlasMapping.ourGroupFor(info.group))
                : null,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingXS.h),
        Text(
          'muscle_atlas_attribution'.tr(),
          textAlign: TextAlign.center,
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral400,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}

/// Minimal front/back segmented toggle, design-system styled.
class _ViewToggle extends StatelessWidget {
  final atlas.AtlasAsset view;
  final ValueChanged<atlas.AtlasAsset> onChanged;

  const _ViewToggle({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(
          label: 'view_front'.tr(),
          selected: view == atlas.AtlasAsset.musclesFront,
          onTap: () => onChanged(atlas.AtlasAsset.musclesFront),
        ),
        SizedBox(width: AppDesignSystem.spacingXS.w),
        _pill(
          label: 'view_back'.tr(),
          selected: view == atlas.AtlasAsset.musclesBack,
          onTap: () => onChanged(atlas.AtlasAsset.musclesBack),
        ),
      ],
    );
  }

  Widget _pill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppDesignSystem.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            border: Border.all(
              color: selected
                  ? AppDesignSystem.primaryStrong
                  : AppDesignSystem.neutral300,
            ),
          ),
          child: Text(
            label,
            style: AppDesignSystem.labelMedium.copyWith(
              color: selected
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral400,
            ),
          ),
        ),
      ),
    );
  }
}
