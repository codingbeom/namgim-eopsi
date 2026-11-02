import 'package:flutter/material.dart';

import '../domain/urgency.dart';

class AppColors {
  static const olive = Color(0xFF345017);
  static const leaf = Color(0xFF97B33F);
  static const accent = Color(0xFFFE8D47);
  static const background = Color(0xFFF4F1E8);
  static const surface = Color(0xFFFFFCF8);
  static const frame = Color(0xFFE3E8D4);
  static const ink = Color(0xFF1C2414);
  static const muted = Color(0xFF5E6754);
  static const line = Color(0xFFE4E0D4);
  static const danger = Color(0xFFB42318);
  static const soon = Color(0xFFC47B12);
  static const freezer = Color(0xFF3D6B82);
  static const pantry = Color(0xFF8A5A32);
}

Color urgencyColor(Urgency urgency) => switch (urgency) {
  Urgency.overdue => AppColors.danger,
  Urgency.today => AppColors.accent,
  Urgency.soon => AppColors.soon,
  Urgency.later => AppColors.leaf,
};

Color storageColor(String label) => switch (label) {
  '냉동' => AppColors.freezer,
  '상온' => AppColors.pantry,
  _ => AppColors.olive,
};

ThemeData buildNamgimTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.olive,
    primary: AppColors.olive,
    onPrimary: Colors.white,
    secondary: AppColors.leaf,
    onSecondary: AppColors.ink,
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'IBMPlexSansKR',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
      fontFamily: 'IBMPlexSansKR',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.olive,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'IBMPlexSansKR',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.olive,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.leaf.withValues(alpha: 0.45),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'IBMPlexSansKR',
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: selected ? AppColors.olive : AppColors.muted,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.olive,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(
          fontFamily: 'IBMPlexSansKR',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.olive,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'IBMPlexSansKR',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      extendedTextStyle: TextStyle(
        fontFamily: 'IBMPlexSansKR',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.olive, width: 1.6),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      // Sits above the bottom navigation bar.
      insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 88),
      contentTextStyle: TextStyle(
        fontFamily: 'IBMPlexSansKR',
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.olive,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.olive,
      labelStyle: TextStyle(
        fontFamily: 'IBMPlexSansKR',
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'IBMPlexSansKR',
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
