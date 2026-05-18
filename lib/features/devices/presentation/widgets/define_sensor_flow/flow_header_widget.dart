import 'package:flutter/material.dart';

import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../define_sensor_widgets.dart';

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
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Título con paso actual
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                DefineSensorWidgets.getStepIcon(currentStep, activationMethod),
                color: Colors.tealAccent,
              ),
              const SizedBox(width: 12),
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
                      style: const TextStyle(color: DashboardColors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Indicador de progreso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(4, (i) {
              final isActive = i <= currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isCurrent ? Colors.tealAccent : DashboardColors.tealAccent50)
                        : DashboardColors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
