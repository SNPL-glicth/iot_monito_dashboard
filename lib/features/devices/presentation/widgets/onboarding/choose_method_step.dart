import 'package:flutter/material.dart';
import '../define_sensor_widgets.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

class ChooseMethodStep extends StatelessWidget {
  final VoidCallback onManualSelected;

  const ChooseMethodStep({
    super.key,
    required this.onManualSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selecciona el método de activación',
          style: TextStyle(
            color: DesignColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        DefineSensorWidgets.methodCard(
          icon: Icons.settings,
          title: 'Configuración manual',
          description: 'Registra el sensor e ingresa la API key en tu gateway.',
          color: Colors.tealAccent,
          onTap: onManualSelected,
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(DesignRadius.md),
          child: Opacity(
            opacity: 0.4,
            child: Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.md),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    child: const Icon(Icons.qr_code, color: Colors.grey, size: 28),
                  ),
                  SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Próximamente',
                          style: TextStyle(
                            color: DesignColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
