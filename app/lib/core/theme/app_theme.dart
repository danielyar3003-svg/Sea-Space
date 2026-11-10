import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class SsTheme {
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: SsColors.accent,
      onPrimary: SsColors.onAccent,
      primaryContainer: SsColors.accentMuted,
      onPrimaryContainer: SsColors.accent,
      secondary: SsColors.accentStrong,
      onSecondary: SsColors.onAccent,
      error: SsColors.danger,
      onError: Colors.white,
      surface: SsColors.surface,
      onSurface: SsColors.textPrimary,
      onSurfaceVariant: SsColors.textSecondary,
      surfaceContainerLowest: SsColors.background,
      surfaceContainerLow: SsColors.surface,
      surfaceContainer: SsColors.surface,
      surfaceContainerHigh: SsColors.surfaceRaised,
      surfaceContainerHighest: SsColors.surfaceHover,
      outline: SsColors.borderStrong,
      outlineVariant: SsColors.border,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
    final text = base.textTheme.apply(bodyColor: SsColors.textPrimary, displayColor: SsColors.textPrimary);

    return base.copyWith(
      scaffoldBackgroundColor: SsColors.background,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: text.labelSmall?.copyWith(
          color: SsColors.textTertiary,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: text.bodySmall?.copyWith(color: SsColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SsColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: SsColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: SsColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: SsRadius.brMd,
          side: BorderSide(color: SsColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: SsColors.border, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SsColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: SsColors.accentMuted,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? SsColors.accent : SsColors.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected) ? SsColors.accent : SsColors.textTertiary,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: SsColors.surface,
        indicatorColor: SsColors.accentMuted,
        selectedIconTheme: IconThemeData(color: SsColors.accent),
        unselectedIconTheme: IconThemeData(color: SsColors.textTertiary),
        selectedLabelTextStyle: TextStyle(color: SsColors.accent, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: SsColors.textSecondary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: SsColors.surfaceRaised,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(color: SsColors.textSecondary),
        hintStyle: TextStyle(color: SsColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: SsRadius.brSm,
          borderSide: BorderSide(color: SsColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SsRadius.brSm,
          borderSide: BorderSide(color: SsColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SsRadius.brSm,
          borderSide: BorderSide(color: SsColors.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: SsRadius.brSm,
          borderSide: BorderSide(color: SsColors.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SsColors.accent,
          foregroundColor: SsColors.onAccent,
          minimumSize: const Size(64, 44),
          shape: const RoundedRectangleBorder(borderRadius: SsRadius.brSm),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SsColors.textPrimary,
          minimumSize: const Size(64, 44),
          side: const BorderSide(color: SsColors.borderStrong),
          shape: const RoundedRectangleBorder(borderRadius: SsRadius.brSm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: SsColors.accent)),
      chipTheme: const ChipThemeData(
        backgroundColor: SsColors.surfaceRaised,
        side: BorderSide(color: SsColors.border),
        shape: RoundedRectangleBorder(borderRadius: SsRadius.brSm),
        labelStyle: TextStyle(color: SsColors.textPrimary, fontSize: 13),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: SsColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SsRadius.brLg,
          side: BorderSide(color: SsColors.border),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: SsColors.surfaceHover,
        contentTextStyle: TextStyle(color: SsColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: SsColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: SsSpace.lg),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: SsColors.accent),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
