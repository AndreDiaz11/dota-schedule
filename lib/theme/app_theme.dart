import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF121214);
  static const surface = Color(0xFF1B1B1F);
  static const divider = Color(0xFF2A2A2F);
  static const headerBackground = Color(0xFFB9D2F3);
  static const headerForeground = Color(0xFF15294D);
  static const accent = Color(0xFF4C7FDD);
  static const accentOnDark = Color(0xFF6C93E0);
  static const chipBackground = Color(0xFF2A2A30);
  static const textPrimary = Color(0xFFF2F2F3);
  static const textSecondary = Color(0xFFA0A0A8);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.headerBackground,
      foregroundColor: AppColors.headerForeground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.headerForeground,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.headerForeground),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textSecondary,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.chipBackground,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      selectedColor: AppColors.accent,
      side: BorderSide.none,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.35),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          color: states.contains(WidgetState.selected) ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.35),
      selectedLabelTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      selectedIconTheme: const IconThemeData(color: AppColors.textPrimary),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : AppColors.textSecondary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
    ),
  );
}
