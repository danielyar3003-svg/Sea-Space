import 'package:flutter/material.dart';

/// SEA SPACE design tokens — "Premium Dark Maritime Intelligence".
///
/// All colours, spacing and radii used by the app come from here so the visual
/// language stays consistent across screens.
abstract final class SsColors {
  // Backgrounds: deep navy → graphite surfaces.
  static const background = Color(0xFF070B14);
  static const surface = Color(0xFF0E141F);
  static const surfaceRaised = Color(0xFF141B28);
  static const surfaceHover = Color(0xFF1A2333);
  static const border = Color(0xFF222C3D);
  static const borderStrong = Color(0xFF2E3A4F);

  // Ice-blue accent.
  static const accent = Color(0xFF8FD0F5);
  static const accentStrong = Color(0xFF5DB4E8);
  static const accentMuted = Color(0xFF1B3346);
  static const onAccent = Color(0xFF04121D);

  // Text.
  static const textPrimary = Color(0xFFE7EDF5);
  static const textSecondary = Color(0xFF9AA7B8);
  static const textTertiary = Color(0xFF657286);

  // Semantic.
  static const success = Color(0xFF4FC48D);
  static const warning = Color(0xFFE2B45A);
  static const danger = Color(0xFFE5675B);
  static const info = accent;
}

abstract final class SsSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Horizontal page gutter.
  static const gutter = 16.0;

  /// Max content width on large screens (web admin, tablets).
  static const maxContentWidth = 1120.0;
}

abstract final class SsRadius {
  static const sm = 6.0;
  static const md = 10.0;
  static const lg = 14.0;

  static const brSm = BorderRadius.all(Radius.circular(sm));
  static const brMd = BorderRadius.all(Radius.circular(md));
  static const brLg = BorderRadius.all(Radius.circular(lg));
}

abstract final class SsMotion {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const curve = Curves.easeOutCubic;
}

/// Layout breakpoints.
abstract final class SsBreakpoints {
  static const medium = 840.0; // switch bottom bar → navigation rail
  static const expanded = 1200.0; // extended rail with labels
}
