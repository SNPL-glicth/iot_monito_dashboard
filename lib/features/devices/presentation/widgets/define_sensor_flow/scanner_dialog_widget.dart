import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/theme/design_colors.dart';

/// Scanner dialog widget for QR code scanning
class ScannerDialogWidget extends StatelessWidget {
  const ScannerDialogWidget({
    super.key,
    required this.onScanned,
  });

  final Function(String) onScanned;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          AppBar(
            title: const Text('Escanear QR del Sensor'),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                if (barcode?.rawValue != null) {
                  Navigator.of(context).pop();
                  onScanned(barcode!.rawValue!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Manual code dialog widget for testing
class ManualCodeDialogWidget extends StatelessWidget {
  const ManualCodeDialogWidget({
    super.key,
    required this.onCodeScanned,
  });

  final Function(String) onCodeScanned;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: const Text('Código del sensor', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Ej: SENSOR-12345',
          hintStyle: TextStyle(color: DesignColors.textDim),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (controller.text.trim().isNotEmpty) {
              onCodeScanned(controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
          child: const Text('Activar'),
        ),
      ],
    );
  }
}
