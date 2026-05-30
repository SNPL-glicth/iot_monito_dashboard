import 'package:flutter/material.dart';
import '../define_sensor_widgets.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Header widget showing current step and progress
class FlowHeaderWidget extends StatelessWidget {
  const FlowHeaderWidget({
    super.key,
    required this.currentStep,
    required this.activationMethod,
    required this.onClose,
  });

  final int currentStep;
  final String activationMethod;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: DesignSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Título con paso actual
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                DefineSensorWidgets.getStepIcon(currentStep, activationMethod),
                color: Colors.tealAccent,
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DefineSensorWidgets.getStepTitle(currentStep, activationMethod),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Paso ${currentStep + 1} de 4',
                      style: TextStyle(color: DesignColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: DesignColors.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        // Indicador de progreso
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(4, (i) {
              final isActive = i <= currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isCurrent ? Colors.tealAccent : DesignColors.cyan.withValues(alpha: 0.5))
                        : DesignColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
      ],
    );
  }
}
