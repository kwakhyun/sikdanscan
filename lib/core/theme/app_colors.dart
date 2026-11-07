import 'package:flutter/material.dart';

/// Brand and semantic colors.
///
/// Fill colors (`primary`, `warning`, ...) are tuned for surfaces, icons and
/// charts. Text or button colors on light backgrounds must use the `*Strong`
/// / `*Text` tokens (or the [AppColorsExtension] getters) so that body text
/// reaches the WCAG AA 4.5:1 contrast ratio.
class AppColors {
  AppColors._();

  // Primary (brand mint). `primary` is a fill color only: it reaches ~1.9:1 on
  // white, so it must not carry text. `primaryStrong` (5.8:1 on white) is the
  // text/button token for light surfaces.
  static const Color primary = Color(0xFF2DD4A8);
  static const Color primaryLight = Color(0xFF6EEBCB);
  static const Color primaryDark = Color(0xFF0FA87E);
  static const Color primaryStrong = Color(0xFF08735A);
  static const Color primarySurface = Color(0xFFE8FBF5);

  // Secondary (coral)
  static const Color secondary = Color(0xFFFF7E67);
  static const Color secondaryLight = Color(0xFFFFAA96);
  static const Color secondaryDark = Color(0xFFE65A42);
  static const Color secondaryStrong = Color(0xFFC2410C);

  // Accent (violet)
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFA29BFE);
  static const Color accentStrong = Color(0xFF5B4BD5);

  // Neutral
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F8);
  static const Color border = Color(0xFFE8ECF2);
  static const Color divider = Color(0xFFF0F2F5);

  // Text (all >= 4.5:1 on surface, background and surfaceVariant)
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF646B7A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status fills (icons, bars, tinted backgrounds)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);

  // Status text on light surfaces
  static const Color successText = Color(0xFF15803D);
  static const Color warningText = Color(0xFFB45309);
  static const Color errorText = Color(0xFFB91C1C);
  static const Color infoText = Color(0xFF1D4ED8);

  // Chart
  static const Color chartCarbs = Color(0xFF6C5CE7);
  static const Color chartProtein = Color(0xFF0FA87E);
  static const Color chartFat = Color(0xFFFF7E67);
  static const Color chartWater = Color(0xFF3B82F6);
  static const Color chartBar = Color(0xFF0FA87E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStrong, Color(0xFF0E7490)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFFFB347)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF08735A), Color(0xFF5B4BD5)],
  );

  // Dark Mode
  static const Color darkPrimarySurface = Color(0xFF0D2E26);

  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D28);
  static const Color darkSurfaceVariant = Color(0xFF242736);
  static const Color darkBorder = Color(0xFF2E3142);
  static const Color darkDivider = Color(0xFF252838);

  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  static const Color darkTextSecondary = Color(0xFFB0B6C6);
  static const Color darkTextTertiary = Color(0xFF8B91A7);

  static const Color darkSuccessText = Color(0xFF4ADE80);
  static const Color darkWarningText = Color(0xFFFBBF24);
  static const Color darkErrorText = Color(0xFFF87171);
  static const Color darkInfoText = Color(0xFF60A5FA);
}

extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get colorBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get colorSurface =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;
  Color get colorSurfaceVariant =>
      isDarkMode ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  Color get colorBorder => isDarkMode ? AppColors.darkBorder : AppColors.border;
  Color get colorDivider =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;
  Color get colorTextPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get colorTextSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get colorTextTertiary =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;
  Color get colorPrimarySurface =>
      isDarkMode ? AppColors.darkPrimarySurface : AppColors.primarySurface;

  /// Brand color for text, icons-with-meaning and outlined controls.
  Color get colorPrimaryText =>
      isDarkMode ? AppColors.primary : AppColors.primaryStrong;
  Color get colorSecondaryText =>
      isDarkMode ? AppColors.secondaryLight : AppColors.secondaryStrong;
  Color get colorAccentText =>
      isDarkMode ? AppColors.accentLight : AppColors.accentStrong;
  Color get colorSuccessText =>
      isDarkMode ? AppColors.darkSuccessText : AppColors.successText;
  Color get colorWarningText =>
      isDarkMode ? AppColors.darkWarningText : AppColors.warningText;
  Color get colorErrorText =>
      isDarkMode ? AppColors.darkErrorText : AppColors.errorText;
  Color get colorInfoText =>
      isDarkMode ? AppColors.darkInfoText : AppColors.infoText;
}
