import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Static brand tokens ────────────────────────────────────────
class AppColors {
  // Brand (theme-invariant) — real UAPP brand colours from CRM app
  static const primary       = Color(0xFF045D5E); // real brand dark teal
  static const primaryLight  = Color(0xFF019088); // lighter teal
  static const primaryDark   = Color(0xFF033F40);
  static const primaryFaint  = Color(0x1A045D5E);
  static const primaryBorder = Color(0x37045D5E);
  static const orange        = Color(0xFFFC7300);
  static const orangeFaint   = Color(0x1AFC7300);
  static const online        = Color(0xFF40E080);
  static const danger        = Color(0xFFFF4F4F);
  static const warn          = Color(0xFFFBBF24);
  static const badgeBg       = Color(0xFF008F91);

  // Dark-mode constants kept for screens not yet updated to C(context)
  static const bg              = Color(0xFF001516);
  static const surface         = Color(0xFF021D1F);
  static const surfaceElevated = Color(0xFF002220);
  static const cardBg          = Color(0xFF0A2A2C);
  static const textPrimary     = Colors.white;
  static const textSecondary   = Color(0xFFB6B6B6);
  static const textMuted       = Color(0xFF5A5A5A);
  static const textHint        = Color(0xFF3A4A4C);
  static const border          = Color(0xFF0D3235);
  static const divider         = Color(0xFF0A2527);
  static const ownBubble       = Color(0xFF045D5E);  // real brand teal
  static const otherBubble     = Color(0xFF1A2E30);
}

// ── Dynamic colour palette (dark / light) ─────────────────────
class AC {
  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textHint;
  final Color border;
  final Color divider;
  final Color ownBubble;
  final Color otherBubble;

  const AC({
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textHint,
    required this.border,
    required this.divider,
    required this.ownBubble,
    required this.otherBubble,
  });
}

// ── Dark palette ──────────────────────────────────────────────
const kDark = AC(
  bg:              Color(0xFF001516),
  surface:         Color(0xFF021D1F),
  surfaceElevated: Color(0xFF002220),
  cardBg:          Color(0xFF0A2A2C),
  textPrimary:     Colors.white,
  textSecondary:   Color(0xFFB6B6B6),
  textMuted:       Color(0xFF5A5A5A),
  textHint:        Color(0xFF3A4A4C),
  border:          Color(0xFF0D3235),
  divider:         Color(0xFF0A2527),
  ownBubble:       Color(0xFF005F61),
  otherBubble:     Color(0xFF1A2E30),
);

// ── Light palette ─────────────────────────────────────────────
const kLight = AC(
  bg:              Color(0xFFF0F9FA),
  surface:         Color(0xFFFFFFFF),
  surfaceElevated: Color(0xFFE8F4F5),
  cardBg:          Color(0xFFFFFFFF),
  textPrimary:     Color(0xFF0F172A),
  textSecondary:   Color(0xFF334155),
  textMuted:       Color(0xFF64748B),
  textHint:        Color(0xFF94A3B8),
  border:          Color(0xFFCCE8E9),
  divider:         Color(0xFFE0F0F0),
  ownBubble:       Color(0xFF045D5E),
  otherBubble:     Color(0xFFE8F4F5),
);

/// Returns the active colour palette from the current theme.
AC C(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? kDark : kLight;

// ── Dark ThemeData ────────────────────────────────────────────
ThemeData buildAppTheme() => _build(Brightness.dark, kDark);

// ── Light ThemeData ───────────────────────────────────────────
ThemeData buildLightTheme() => _build(Brightness.light, kLight);

ThemeData _build(Brightness brightness, AC c) {
  final isDark = brightness == Brightness.dark;

  final textTheme = TextTheme(
    displayLarge:  TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
    headlineMedium:TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
    headlineSmall: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
    titleLarge:    TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
    titleMedium:   TextStyle(color: c.textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
    titleSmall:    TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
    bodyLarge:     TextStyle(color: c.textPrimary, fontSize: 15),
    bodyMedium:    TextStyle(color: c.textSecondary, fontSize: 13.5),
    bodySmall:     TextStyle(color: c.textMuted, fontSize: 12),
    labelLarge:    TextStyle(color: c.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
    labelSmall:    TextStyle(color: c.textMuted, fontSize: 11),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.bg,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.orange,
            surface: c.surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: c.textPrimary,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.orange,
            surface: c.surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: c.textPrimary,
          ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: c.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: c.surface,
      ),
      titleTextStyle: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: c.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dividerColor: c.divider,
    dividerTheme: DividerThemeData(color: c.divider, thickness: 1),
    cardColor: c.surface,
    dialogBackgroundColor: c.surface,
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
  );
}
