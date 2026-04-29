import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  static const Color backgroundDark = Color(0xFF0F0A24);
  static const Color surfaceDark = Color(0xFF1A1035);
  static const Color surfaceVariantDark = Color(0xFF241847);
  static const Color surfaceElevated = Color(0xFF2D1F5E);

  static const Color glassSurface = Color(0x12FFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderBright = Color(0x33FFFFFF);

  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0x1A10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0x1AEF4444);

  static const Color textPrimary = Color(0xFFF1F0FF);
  static const Color textSecondary = Color(0xFFB4B0CC);
  static const Color textMuted = Color(0xFF6B6880);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A1B5E), Color(0xFF1A2A6C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, Color(0xFF0D1B3E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: surfaceVariantDark,
      secondary: secondary,
      secondaryContainer: Color(0xFF1E3A6E),
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
      outline: glassBorder,
      outlineVariant: Color(0xFF2E2A4A),
      inverseSurface: textPrimary,
      onInverseSurface: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.4,
        ),
      ),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: glassSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: glassBorder, width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: primary.withAlpha(77),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryLight,
          );
        }
        return GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryLight, size: 24);
        }
        return const IconThemeData(color: textMuted, size: 22);
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2E2A4A),
      thickness: 1,
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight.withAlpha(51),
      secondary: secondary,
      surface: const Color(0xFFF5F3FF),
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1A1035),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F3FF),
    textTheme: GoogleFonts.outfitTextTheme(),
  );
}
