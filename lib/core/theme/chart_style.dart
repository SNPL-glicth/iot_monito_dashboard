import 'package:flutter/material.dart';
import '../../core/theme/design_spacing.dart';

/// Unified chart styling for consistent visualization across the app.
/// 
/// FASE 2.4: This class defines a consistent visual language for all charts,
/// including colors, line widths, and styling for ML features.
class ChartStyle {
  ChartStyle._();
  
  // ============================================================================
  // COLORS - Consistent color palette for all charts
  // ============================================================================
  
  /// Primary value line color (blue for actual readings)
  static const Color valueLineColor = Color(0xFF2196F3);
  
  /// ML Baseline line color (gray, dashed)
  static const Color baselineColor = Color(0xFF9E9E9E);
  
  /// Confidence band color (green with transparency)
  static const Color confidenceBandColor = Color(0x334CAF50);
  
  /// Confidence band border color
  static const Color confidenceBorderColor = Color(0xFF4CAF50);
  
  /// Alert threshold color (red)
  static const Color alertColor = Color(0xFFF44336);
  
  /// Warning threshold color (orange)
  static const Color warningColor = Color(0xFFFF9800);
  
  /// Normal state color (green)
  static const Color normalColor = Color(0xFF4CAF50);
  
  /// Prediction line color (purple, dashed)
  static const Color predictionColor = Color(0xFF9C27B0);
  
  /// Grid line color
  static const Color gridColor = Color(0x0FFFFFFF);
  
  /// Chart background color
  static const Color backgroundColor = Color(0xFF1A1F2E);
  
  /// Chart border color
  static const Color borderColor = Color(0x1AFFFFFF);
  
  /// Text color for labels
  static const Color labelColor = Color(0x80FFFFFF);
  
  /// Tooltip background color
  static const Color tooltipBackground = Color(0xFF2A2F3E);
  
  // ============================================================================
  // LINE WIDTHS
  // ============================================================================
  
  /// Main value line width
  static const double valueLineWidth = 2.5;
  
  /// Baseline line width
  static const double baselineLineWidth = 1.5;
  
  /// Threshold line width
  static const double thresholdLineWidth = 1.5;
  
  /// Grid line width
  static const double gridLineWidth = 1.0;
  
  // ============================================================================
  // DOT SIZES
  // ============================================================================
  
  /// Normal dot radius
  static const double normalDotRadius = 2.0;
  
  /// Alert dot radius
  static const double alertDotRadius = 6.0;
  
  /// Warning dot radius
  static const double warningDotRadius = 5.0;
  
  /// Dot stroke width
  static const double dotStrokeWidth = 2.0;
  
  // ============================================================================
  // DASH PATTERNS
  // ============================================================================
  
  /// Baseline dash pattern
  static const List<int> baselineDash = [8, 4];
  
  /// Threshold dash pattern
  static const List<int> thresholdDash = [5, 3];
  
  /// Prediction dash pattern
  static const List<int> predictionDash = [4, 4];
  
  // ============================================================================
  // FONT SIZES
  // ============================================================================
  
  /// Axis label font size
  static const double axisLabelSize = 10.0;
  
  /// Tooltip font size
  static const double tooltipFontSize = 12.0;
  
  /// Legend font size
  static const double legendFontSize = 10.0;
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get color for a given state
  static Color getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'ALERT':
      case 'CRITICAL':
        return alertColor;
      case 'WARNING':
      case 'WARN':
        return warningColor;
      case 'NORMAL':
      case 'OK':
        return normalColor;
      default:
        return valueLineColor;
    }
  }
  
  /// Get color for confidence level (0-1)
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return normalColor;
    if (confidence >= 0.5) return warningColor;
    return alertColor;
  }
  
  /// Get color for anomaly score (0-1)
  static Color getAnomalyColor(double score) {
    if (score >= 0.7) return alertColor;
    if (score >= 0.4) return warningColor;
    return normalColor;
  }
  
  /// Get text style for axis labels
  static TextStyle get axisLabelStyle => TextStyle(
    color: labelColor,
    fontSize: axisLabelSize,
  );
  
  /// Get text style for tooltips
  static TextStyle tooltipStyle({Color? color}) => TextStyle(
    color: color ?? Colors.white,
    fontSize: tooltipFontSize,
    fontWeight: FontWeight.w500,
  );
  
  /// Get text style for legends
  static TextStyle get legendStyle => TextStyle(
    color: labelColor,
    fontSize: legendFontSize,
  );
  
  /// Get box decoration for chart container
  static BoxDecoration get chartContainerDecoration => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(DesignRadius.md),
    border: Border.all(color: borderColor),
  );
}

/// Extension for easy color manipulation
extension ColorExtension on Color {
  /// Get color with custom opacity
  Color withOpacityValue(double opacity) => withValues(alpha: opacity);
}
