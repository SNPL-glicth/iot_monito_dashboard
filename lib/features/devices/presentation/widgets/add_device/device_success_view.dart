import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Vista de éxito después de crear un dispositivo.
class DeviceSuccessView extends StatelessWidget {
  const DeviceSuccessView({
    super.key,
    required this.deviceName,
    required this.deviceUuid,
    required this.deviceId,
  });

  final String deviceName;
  final String deviceUuid;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: DashboardColors.gradientSuccess,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.success.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dispositivo Creado!',
            style: DashboardTextStyles.sectionHeader,
          ),
          const SizedBox(height: 8),
          Text(
            'Ahora puedes agregar sensores a este dispositivo',
            textAlign: TextAlign.center,
            style: DashboardTextStyles.sensorMeta,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ModernCardDecoration.elevated(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DashboardColors.primaryAccent10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.info_outline_rounded, color: DashboardColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Detalles', style: DashboardTextStyles.deviceTitle),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow('Nombre', deviceName),
                _infoRow('UUID', deviceUuid),
                _infoRow('Estado', 'Esperando activación'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ModernCardDecoration.elevated(color: DashboardColors.cardBackgroundLight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DashboardColors.orangeAccent15,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, color: DashboardColors.warning, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text('Próximos pasos', style: DashboardTextStyles.deviceTitle),
                  ],
                ),
                const SizedBox(height: 16),
                _stepItem('1', 'Agregar sensores al dispositivo'),
                _stepItem('2', 'Escanear QR del hardware físico'),
                _stepItem('3', 'El dispositivo se activará automáticamente'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DashboardColors.white70,
                    side: BorderSide(color: DashboardColors.white12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Volver'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/device/$deviceId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DashboardColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Agregar Sensores'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DashboardTextStyles.sensorMeta),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: DashboardColors.primaryAccent10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(number, style: TextStyle(color: DashboardColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: DashboardTextStyles.sensorMeta),
          ),
        ],
      ),
    );
  }
}
