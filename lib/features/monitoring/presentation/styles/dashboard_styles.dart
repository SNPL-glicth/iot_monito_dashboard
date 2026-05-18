/// Estilos globales de texto y colores para el dashboard monitoring.
/// Diseño moderno con glassmorphism y gradientes sutiles.
library;

import 'package:flutter/material.dart';

class DashboardTextStyles {
  // MODERN: Tipografía limpia y jerarquía clara
  static const sectionHeader = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const deviceTitle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const deviceSubtitle = TextStyle(
    color: Color(0x99FFFFFF),
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const sensorTitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const sensorMeta = TextStyle(
    color: Color(0x99FFFFFF),
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const smallLabel = TextStyle(
    color: Color(0x80FFFFFF),
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const chipActive = TextStyle(
    color: Color(0xFF4ADE80),
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const chipInactive = TextStyle(
    color: Color(0xFFF87171),
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const alertTitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const alertText = TextStyle(
    color: Color(0xB3FFFFFF),
    fontSize: 13,
  );

  static const error = TextStyle(
    color: Color(0xFFF87171),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const appBarRoleChip = TextStyle(
    color: Color(0x99FFFFFF),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const drawerHeaderTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const drawerHeaderSubtitle = TextStyle(
    color: Color(0x99FFFFFF),
    fontSize: 13,
  );
  
  // NUEVOS: Estilos para KPIs modernos
  static const kpiValue = TextStyle(
    color: Colors.white,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
  );
  
  static const kpiLabel = TextStyle(
    color: Color(0x99FFFFFF),
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static const kpiDelta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

// Colores modernos del dashboard con gradientes y glassmorphism
class DashboardColors {
  // Fondos principales - Paleta oscura moderna
  static const background = Color(0xFF0A0E1A);
  static const cardBackground = Color(0xFF131A2B);
  static const cardBackgroundLight = Color(0xFF1A2235);
  static const surfaceElevated = Color(0xFF1E2642);

  // Colores de acento modernos
  static const primary = Color(0xFF6366F1);       // Indigo moderno
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF22D3EE);     // Cyan vibrante
  static const accent = Color(0xFF14F195);        // Verde neón
  
  // Estados semánticos
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);
  static const info = Color(0xFF60A5FA);

  // Iconos y elementos
  static const sensorIcon = Color(0xFF22D3EE);
  static const deviceOnline = Color(0xFF4ADE80);
  static const deviceOffline = Color(0xFFF87171);
  static const sectionAccent = Color(0xFF6366F1);

  // Blancos con opacidad
  static const white70 = Color(0xB3FFFFFF);
  static const white54 = Color(0x8AFFFFFF);
  static const white12 = Color(0x1FFFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white05 = Color(0x0DFFFFFF);
  static const white06 = Color(0x0FFFFFFF);
  
  // Gradientes para cards
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );
  
  static const gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );
  
  static const gradientWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
  );
  
  static const gradientError = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );
  
  // Colores con opacidad pre-calculados
  static const tealAccent10 = Color(0x1A22D3EE);
  static const tealAccent30 = Color(0x4D22D3EE);
  static const tealAccent50 = Color(0x8022D3EE);
  static const greenAccent10 = Color(0x1A4ADE80);
  static const greenAccent15 = Color(0x264ADE80);
  static const greenAccent30 = Color(0x4D4ADE80);
  static const redAccent15 = Color(0x26F87171);
  static const redAccent30 = Color(0x4DF87171);
  static const blueAccent10 = Color(0x1A60A5FA);
  static const blueAccent30 = Color(0x4D60A5FA);
  static const orangeAccent15 = Color(0x26FBBF24);
  static const orangeAccent50 = Color(0x80FBBF24);
  static const primaryAccent10 = Color(0x1A6366F1);
  static const primaryAccent20 = Color(0x336366F1);
}

// Widget helpers para diseño moderno
class ModernCardDecoration {
  static BoxDecoration glass({Color? color, double opacity = 0.1}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    );
  }
  
  static BoxDecoration gradient(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  static BoxDecoration elevated({Color? color}) {
    return BoxDecoration(
      color: color ?? DashboardColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.05),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
