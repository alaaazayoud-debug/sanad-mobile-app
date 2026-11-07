import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SanadTheme {
  // ══════════════════════════════════════════
  // Brand Colors (Premium Trust Blue)
  // ══════════════════════════════════════════
  static const Color primaryBlue = Color(0xFF1E3A8A); // أزرق بنكي عميق (موثوقية)
  static const Color primaryBlueLight = Color(0xFF2563EB); // أزرق ساطع للأزرار
  static const Color accentGold = Color(0xFFD4AF37); // ذهبي هادئ للمسات الفخمة

  // ══════════════════════════════════════════
  // Light Mode Colors (Clean & Minimalist)
  // ══════════════════════════════════════════
  static const Color background = Color(0xFFF8FAFC); // خلفية رمادية فاتحة جداً
  static const Color surface = Color(0xFFFFFFFF); // أبيض ناصع للبطاقات
  static const Color surfaceLight = Color(0xFFF1F5F9); // رمادي فاتح جداً للحقول
  static const Color border = Color(0xFFE2E8F0); // حدود ناعمة

  // ══════════════════════════════════════════
  // Text Colors
  // ══════════════════════════════════════════
  static const Color textPrimary = Color(0xFF0F172A); // أسود/كحلي عميق جداً
  static const Color textSecondary = Color(0xFF475569); // رمادي متوسط
  static const Color textMuted = Color(0xFF94A3B8); // رمادي فاتح

  // ══════════════════════════════════════════
  // Semantic Colors (Financial)
  // ══════════════════════════════════════════
  static const Color success = Color(0xFF059669); // أخضر مالي
  static const Color error = Color(0xFFDC2626); // أحمر تنبيهي
  static const Color warning = Color(0xFFD97706); // برتقالي تحذيري

  // ══════════════════════════════════════════
  // Transaction Colors
  // ══════════════════════════════════════════
  static const Color invoiceColor = error; // أحمر — فاتورة (مبلغ مستحق الدفع)
  static const Color paymentColor = success; // أخضر — دفعة (استلام مبلغ)
  static const Color returnColor = warning; // برتقالي — استرجاع

  // ══════════════════════════════════════════
  // Geometry & Shadows
  // ══════════════════════════════════════════
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusRound = 99.0;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // ══════════════════════════════════════════
  // Typography: Tajawal (Elegant Arabic Font)
  // ══════════════════════════════════════════
  static TextTheme get _textTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.tajawal(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.tajawal(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.tajawal(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: GoogleFonts.tajawal(
        color: textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      // Inter للأرقام لأنها أوضح مالياً
      labelLarge: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.inter(
        color: textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ══════════════════════════════════════════
  // Theme Data (Light Theme Only for now)
  // ══════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentGold,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        titleTextStyle: GoogleFonts.tajawal(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlueLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryBlueLight, width: 2),
        ),
        hintStyle: GoogleFonts.tajawal(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.tajawal(color: textSecondary, fontSize: 14),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      
      // Text
      textTheme: _textTheme,
    );
  }
}
