import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Brand colours ──────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const bg = Color(0xFF001516);
  static const surface = Color(0xFF021D1F);
  static const surfaceElevated = Color(0xFF002220);
  static const cardBg = Color(0xFF0A2A2C);

  // Primary teal
  static const primary = Color(0xFF008F91);
  static const primaryLight = Color(0xFF05BEC0);
  static const primaryDark = Color(0xFF006567);
  static const primaryFaint = Color(0x1A008F91);

  // Orange accent
  static const orange = Color(0xFFFC7300);
  static const orangeFaint = Color(0x1AFC7300);

  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB6B6B6);
  static const textMuted = Color(0xFF5A5A5A);
  static const textHint = Color(0xFF3A4A4C);

  // Borders & dividers
  static const border = Color(0xFF0D3235);
  static const divider = Color(0xFF0A2527);

  // Status
  static const online = Color(0xFF40E080);
  static const danger = Color(0xFFFF4F4F);
  static const warn = Color(0xFFFBBF24);

  // Own message bubble
  static const ownBubble = Color(0xFF005F61);
  static const otherBubble = Color(0xFF1A2E30);

  // Unread badge
  static const badgeBg = Color(0xFF008F91);

  // Primary border (teal at 22% opacity)
  static const primaryBorder = Color(0x37008F91);
}

// ── Theme ──────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  const textTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
    headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
    headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
    titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
    titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
    titleSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
    bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
    bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
    labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    labelSmall: TextStyle(color: AppColors.textMuted, fontSize: 11),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.orange,
      surface: AppColors.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.surface,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dividerColor: AppColors.divider,
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
  );
}
