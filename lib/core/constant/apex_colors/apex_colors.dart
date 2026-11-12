import 'package:flutter/material.dart';

/// Apex v3 — the design language's single colour source of truth.
///
/// Holds BOTH the dark palette (the shipping "hero" mode) and the light "day"
/// palette (defined for a future runtime toggle; not wired to a switch yet).
/// [AppDesignSystem] and the `AppColors` extension re-point their static tokens
/// at these values, so the whole app re-skins from this one file.
///
/// Validated: the two chart series each pass colour-blind separation + surface
/// contrast on their own ground; Volt-on-ink is 15.4:1, Blaze-on-ink 6.8:1.
class ApexColors {
  ApexColors._();

  // ---- Brand: Volt "Lime Spark" (acid lime) — the primary -----------------
  // Base = #B6FF2E ("Lime Spark"). Kept as an ACCENT, never a large fill:
  // one confident lime element per screen; text ON it is always [onLime] ink.
  static const Color volt = Color(0xFFB6FF2E);
  static const Color voltStrongDark = Color(0xFFC6FF52); // readable lime text on dark
  static const Color voltStrongLight = Color(0xFF567A00); // readable lime text on light
  static const Color voltDeep = Color(0xFF97DB00); // pressed / active lime
  static const Color onLime = Color(0xFF0E1500); // near-black ink ON lime fills
  static const Color limeSoftDark = Color(0xFF1B260A);
  static const Color limeSoftLight = Color(0xFFEAF9C4);

  // ---- Energy: Blaze (orange) --------------------------------------------
  static const Color blaze = Color(0xFFFF6A1A);
  static const Color blazeStrongDark = Color(0xFFFF8038);
  static const Color blazeStrongLight = Color(0xFFD9530F);
  static const Color onBlaze = Color(0xFFFFFFFF);
  static const Color blazeSoftDark = Color(0xFF2A1608);
  static const Color blazeSoftLight = Color(0xFFFCE6D6);

  // ---- Dark neutrals: "Graphite" (hero mode) -----------------------------
  // Cool blue-graphite ramp. The elevated overlay lands exactly on the
  // reference Graphite (#23262F); the canvas stays a deep near-black so cards
  // keep real, layered depth above it (canvas < raised < sunken < overlay).
  static const Color darkCanvas = Color(0xFF0B0D12);
  static const Color darkRaised = Color(0xFF161922);
  static const Color darkSunken = Color(0xFF1C202A);
  static const Color darkOverlay = Color(0xFF23262F); // reference "Graphite"
  static const Color darkBorder = Color(0xFF2A2E39);
  static const Color darkBorderStrong = Color(0xFF3B4150);
  static const Color darkText = Color(0xFFF2F4F7); // crisp cool white on graphite
  static const Color darkMuted = Color(0xFF9AA1AD);
  static const Color darkFaint = Color(0xFF5D636E);

  // ---- Light neutrals (day mode; defined, not yet wired) -----------------
  static const Color lightCanvas = Color(0xFFEFEFEA);
  static const Color lightRaised = Color(0xFFFFFFFF);
  static const Color lightSunken = Color(0xFFE3E4DD);
  static const Color lightOverlay = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0E1D9);
  static const Color lightBorderStrong = Color(0xFFCBCDC2);
  static const Color lightText = Color(0xFF0E100D);
  static const Color lightMuted = Color(0xFF54584F);
  static const Color lightFaint = Color(0xFF898D82);

  // ---- Status (dark / light) ---------------------------------------------
  static const Color goodDark = Color(0xFF2FCF9E);
  static const Color goodLight = Color(0xFF12946F);
  static const Color goodSoftDark = Color(0xFF0E2A22);
  static const Color goodSoftLight = Color(0xFFD7F0E6);
  static const Color warnDark = Color(0xFFE7A83A);
  static const Color warnLight = Color(0xFFC77A00);
  static const Color warnSoftDark = Color(0xFF2C2210);
  static const Color warnSoftLight = Color(0xFFFBEBCC);
  static const Color critDark = Color(0xFFF0605B);
  static const Color critLight = Color(0xFFD93A34);
  static const Color critSoftDark = Color(0xFF2E1514);
  static const Color critSoftLight = Color(0xFFFADAD8);
  static const Color infoDark = Color(0xFF4C86E8);
  static const Color infoLight = Color(0xFF2E7DE0);
  static const Color infoSoftDark = Color(0xFF16223A);
  static const Color infoSoftLight = Color(0xFFDDEBFB);

  // ---- Data-viz categorical (validated per surface) ----------------------
  // Fixed order: [orange, teal, blue, magenta, violet]. Lime & orange are
  // reserved for brand/energy, so they are NOT part of the multi-series set.
  static const List<Color> chartDark = [
    Color(0xFFEC6017),
    Color(0xFF12A090),
    Color(0xFF4C86E8),
    Color(0xFFD5539B),
    Color(0xFF9A7BF2),
  ];
  static const List<Color> chartLight = [
    Color(0xFFD9530F),
    Color(0xFF0E9E8C),
    Color(0xFF2E7DE0),
    Color(0xFFC42C7E),
    Color(0xFF6D5EF6),
  ];

  // Macro roles (dark): protein=violet, carbs=blue, fat=teal, calories=orange.
  static const Color macroProteinDark = Color(0xFF9A7BF2);
  static const Color macroCarbsDark = Color(0xFF4C86E8);
  static const Color macroFatDark = Color(0xFF12A090);
  static const Color macroCaloriesDark = Color(0xFFEC6017);
}
