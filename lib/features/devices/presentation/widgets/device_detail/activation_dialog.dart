import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/provisioning_repository.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Muestra diálogo de carga y luego el QR de activación del dispositivo.
Future<void> showActivationDialog({
  required BuildContext context,
  required ProvisioningRepository provRepo,
  required String deviceUuid,
  required String deviceName,
  required VoidCallback onActivated,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const AlertDialog(
      backgroundColor: Color(0xFF1E293B),
      title: Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Preparando activación...'),
        ],
      ),
      content: Text('Generando código QR para el firmware'),
    ),
  );

  try {
    final result = await provRepo.prepareActivation(deviceUuid: deviceUuid);
    if (!context.mounted) return;
    Navigator.of(context).pop(); // Cerrar loading

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.tealAccent),
            SizedBox(width: 8),
            Expanded(child: Text('Activar $deviceName', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: QrImageView(
                data: result.qrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Código: ${result.provisioningCode}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.tealAccent),
            ),
            SizedBox(height: 12),
            Text(
              'Escanee este QR con el firmware del dispositivo para activarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onActivated();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop(); // Cerrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
        backgroundColor: DesignColors.red,
      ),
    );
  }
}
