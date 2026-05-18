import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Card para eliminar todas las lecturas de sensores.
class DeleteAllReadingsCard extends StatelessWidget {
  const DeleteAllReadingsCard({
    super.key,
    required this.isBusy,
    required this.onConfirm,
  });

  final bool isBusy;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DashboardColors.redAccent15,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_forever_rounded, color: DashboardColors.error, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eliminar TODAS las lecturas', style: DashboardTextStyles.deviceTitle),
                    SizedBox(height: 2),
                    Text('Borra todas las filas de lecturas. Ideal para reiniciar entorno demo.', style: DashboardTextStyles.sensorMeta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isBusy ? null : onConfirm,
              child: isBusy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar todas las lecturas'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
