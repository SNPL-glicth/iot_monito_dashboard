import 'package:flutter/material.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';


/// Widgets helper reutilizables para DefineSensorFlow
class DefineSensorWidgets {
  static Widget thresholdSection({
    required String title,
    required Color color,
    required TextEditingController minController,
    required TextEditingController maxController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: DesignSpacing.sm),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Mínimo',
                  hintText: 'Opcional',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: TextFormField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Máximo',
                  hintText: 'Opcional',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget methodCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(DesignRadius.md),
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(width: DesignSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: DesignSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  static Widget usageOption(IconData icon, String title, String detail) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: DesignColors.textSecondary, size: 20),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text(detail, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget errorWidget(String error) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      margin: EdgeInsets.only(bottom: DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: DesignColors.red, size: 20),
          SizedBox(width: DesignSpacing.sm),
          Expanded(child: Text(error, style: TextStyle(color: DesignColors.red))),
        ],
      ),
    );
  }

  static IconData getStepIcon(int currentStep, String activationMethod) {
    switch (currentStep) {
      case 0:
        return Icons.tune;
      case 1:
        return Icons.touch_app;
      case 2:
        return activationMethod == 'qr' ? Icons.qr_code_scanner : Icons.link;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.sensors;
    }
  }

  static String getStepTitle(int currentStep, String activationMethod) {
    switch (currentStep) {
      case 0:
        return 'Definir Métricas';
      case 1:
        return 'Elegir Método';
      case 2:
        return activationMethod == 'qr' ? 'Escanear QR' : 'Código de Activación';
      case 3:
        return '¡Sensor Activado!';
      default:
        return 'Agregar Sensor';
    }
  }
}
