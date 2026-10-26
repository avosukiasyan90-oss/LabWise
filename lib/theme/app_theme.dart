import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const teal = Color(0xFF0B6E6A);
  static const tealDark = Color(0xFF084F4C);
  static const mint = Color(0xFFD8EFEA);
  static const mist = Color(0xFFF3F8F6);
  static const sand = Color(0xFFF7F3EC);
  static const ink = Color(0xFF1A2B2A);
  static const muted = Color(0xFF5C6F6D);
  static const amber = Color(0xFFC4783A);
  static const coral = Color(0xFFC45C4A);
  static const sage = Color(0xFF3D8B6E);
  static const line = Color(0xFFD5E3DF);
}

class AppTheme {
  static ThemeData get light {
    final display = GoogleFonts.frauncesTextTheme();
    final body = GoogleFonts.sourceSans3TextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.mist,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
        secondary: AppColors.amber,
        surface: Colors.white,
        error: AppColors.coral,
        brightness: Brightness.light,
      ),
      textTheme: body.copyWith(
        displayLarge: display.displayLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
        displayMedium: display.displayMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: body.titleLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: body.titleMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          color: AppColors.ink,
          height: 1.45,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          color: AppColors.muted,
          height: 1.45,
        ),
        labelLarge: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: AppColors.mint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.tealDark : AppColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.tealDark : AppColors.muted,
            size: 24,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealDark,
          side: const BorderSide(color: AppColors.line, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.sourceSans3(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
