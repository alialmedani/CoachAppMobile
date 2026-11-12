import 'package:flutter_body_atlas/flutter_body_atlas.dart' as atlas;

import 'package:coachappmobile/features/coach/exercises/data/model/exercise_enums.dart';

/// Bridges our coarse [MuscleGroup] enum and the granular, per-side muscle model
/// of the `flutter_body_atlas` package (whose own `MuscleGroup` is imported here
/// as `atlas.MuscleGroup` to avoid the name clash).
///
/// - [musclesFor] → the package `MuscleInfo` set to highlight for one of our
///   groups (the atlas paints only the ids present on the current front/back
///   layer, so passing the full set is safe).
/// - [defaultView] → the layer where a group is most visible.
/// - [ourGroupFor] → reverse lookup for the interactive coach picker: the tapped
///   muscle's package group mapped back onto our enum.
abstract final class MuscleAtlasMapping {
  /// Package muscles to highlight for [g]. Empty for non-anatomical groups
  /// (other / cardio) — callers should hide the atlas in that case.
  static List<atlas.MuscleInfo> musclesFor(MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest:
        return atlas.MuscleCatalog.chest;
      case MuscleGroup.back:
        return atlas.MuscleCatalog.back;
      case MuscleGroup.shoulders:
        return atlas.MuscleCatalog.shoulders;
      case MuscleGroup.arms:
        return atlas.MuscleCatalog.arms;
      case MuscleGroup.legs:
        // Our "legs" is coarse: fold in the package's lower-body groups.
        return const <atlas.MuscleInfo>[
          ...atlas.MuscleCatalog.legs,
          ...atlas.MuscleCatalog.hamstrings,
          ...atlas.MuscleCatalog.glutes,
          ...atlas.MuscleCatalog.adductors,
        ];
      case MuscleGroup.core:
        return atlas.MuscleCatalog.core;
      case MuscleGroup.fullBody:
        return atlas.MuscleCatalog.all;
      case MuscleGroup.cardio:
      case MuscleGroup.other:
        return const <atlas.MuscleInfo>[];
    }
  }

  /// Whether an interactive/animated atlas makes sense for [g] (i.e. it maps to
  /// real muscles).
  static bool hasMuscles(MuscleGroup g) => musclesFor(g).isNotEmpty;

  /// The layer where [g] reads best: back for back muscles, front otherwise.
  static atlas.AtlasAsset defaultView(MuscleGroup g) =>
      g == MuscleGroup.back
          ? atlas.AtlasAsset.musclesBack
          : atlas.AtlasAsset.musclesFront;

  /// Reverse map: which of OUR groups a tapped package muscle belongs to.
  /// `neck` folds into shoulders (nearest coarse bucket we have); the package's
  /// lower-body groups fold into legs.
  static MuscleGroup ourGroupFor(atlas.MuscleGroup g) {
    switch (g) {
      case atlas.MuscleGroup.chest:
        return MuscleGroup.chest;
      case atlas.MuscleGroup.back:
        return MuscleGroup.back;
      case atlas.MuscleGroup.shoulders:
      case atlas.MuscleGroup.neck:
        return MuscleGroup.shoulders;
      case atlas.MuscleGroup.arms:
        return MuscleGroup.arms;
      case atlas.MuscleGroup.legs:
      case atlas.MuscleGroup.hamstrings:
      case atlas.MuscleGroup.glutes:
      case atlas.MuscleGroup.adductors:
        return MuscleGroup.legs;
      case atlas.MuscleGroup.core:
        return MuscleGroup.core;
    }
  }
}
