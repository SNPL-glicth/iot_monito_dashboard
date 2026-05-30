import 'package:flutter/material.dart';
import 'design_colors.dart';
import 'design_text_styles.dart';
import '../../core/theme/design_spacing.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DesignColors.cyan,
        error: DesignColors.red,
        surface: DesignColors.surface,
        onSurface: DesignColors.textPrimary,
      ),
      scaffoldBackgroundColor: DesignColors.background,
      cardTheme: CardThemeData(
        color: DesignColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          side: BorderSide(color: DesignColors.border, width: 0.5),
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: DesignTextStyles.bodyText,
        bodySmall: DesignTextStyles.timestamp,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignColors.surface2,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: DesignColors.border),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: DesignColors.cyan),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        labelStyle: DesignTextStyles.bodyText,
        hintStyle: DesignTextStyles.bodyText.copyWith(color: DesignColors.textDim),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DesignColors.surface,
        foregroundColor: DesignColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: DesignColors.border, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: DesignColors.border,
        thickness: 0.5,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        textColor: DesignColors.textSecondary,
        iconColor: DesignColors.cyan,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.cyan,
          foregroundColor: DesignColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignColors.cyan,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DesignColors.surface,
        titleTextStyle: DesignTextStyles.cardTitle,
        contentTextStyle: DesignTextStyles.bodyText,
      ),
    );
  }
}
