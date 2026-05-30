import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_colors.dart';

abstract final class DesignTextStyles {
  // Numeric — JetBrains Mono
  static TextStyle get kpiValue => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: DesignColors.cyan,
      );

  static TextStyle get sensorValue => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: DesignColors.textPrimary,
      );

  static TextStyle get metricValue => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: DesignColors.textPrimary,
      );

  static TextStyle get timestamp => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: DesignColors.textDim,
      );

  static TextStyle get deviceId => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: DesignColors.textDim,
      );

  // Labels — Inter
  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DesignColors.textPrimary,
        letterSpacing: 3,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: DesignColors.textSecondary,
        letterSpacing: 2,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: DesignColors.textPrimary,
      );

  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: DesignColors.textSecondary,
      );

  static TextStyle badgeText({Color? color}) => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        color: color ?? DesignColors.textSecondary,
        letterSpacing: 1,
      );
}
