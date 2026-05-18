import 'package:flutter/material.dart';

import 'sensor_types_config.dart';
import 'define_sensor_flow/define_sensor_flow_controller.dart';
import 'define_sensor_flow/define_sensor_flow_content_widget.dart';
import 'define_sensor_flow/scanner_dialog_widget.dart';

/// Flujo completo para agregar un sensor IoT (paso a paso)
///
/// PASOS:
/// 1. Definir métricas (tipo, unidad, umbrales) - SIN nombre
/// 2. Escanear QR del sensor físico (el QR viene del hardware)
/// 3. Activar sensor (recibe nombre del QR escaneado)
class DefineSensorFlow extends StatefulWidget {
  final String deviceUuid;
  final String deviceName;
  final VoidCallback? onSensorCreated;

  const DefineSensorFlow({
    super.key,
    required this.deviceUuid,
    required this.deviceName,
    this.onSensorCreated,
  });

  static Future<dynamic> show(
    BuildContext context, {
    required String deviceUuid,
    required String deviceName,
    VoidCallback? onSensorCreated,
  }) {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DefineSensorFlow(
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        onSensorCreated: onSensorCreated,
      ),
    );
  }

  @override
  State<DefineSensorFlow> createState() => _DefineSensorFlowState();
}

class _DefineSensorFlowState extends State<DefineSensorFlow> {
  final _formKey = GlobalKey<FormState>();
  final _warningMinController = TextEditingController();
  final _warningMaxController = TextEditingController();
  final _alertMinController = TextEditingController();
  final _alertMaxController = TextEditingController();
  late final DefineSensorFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DefineSensorFlowController(onStateChanged: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _warningMinController.dispose();
    _warningMaxController.dispose();
    _alertMinController.dispose();
    _alertMaxController.dispose();
    super.dispose();
  }

  /// PASO 1: Definir sensor (solo métricas)
  Future<void> _defineSensor() async {
    if (!_formKey.currentState!.validate()) return;

    final unit = SensorTypesConfig.getUnit(_controller.selectedType);
    await _controller.defineSensor(
      deviceUuid: widget.deviceUuid,
      unit: unit,
      warningMin: double.tryParse(_warningMinController.text),
      warningMax: double.tryParse(_warningMaxController.text),
      alertMin: double.tryParse(_alertMinController.text),
      alertMax: double.tryParse(_alertMaxController.text),
    );
  }

  /// PASO 2: Activar sensor con el código escaneado del hardware
  Future<void> _activateSensorWithCode(String scannedCode) async {
    await _controller.activateSensorWithCode(scannedCode);
    widget.onSensorCreated?.call();
  }

  void _showManualCodeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ManualCodeDialogWidget(
        onCodeScanned: _handleScannedQR,
      ),
    );
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => ScannerDialogWidget(
        onScanned: _handleScannedQR,
      ),
    );
  }

  void _handleScannedQR(String qrData) {
    final sensorCode = _controller.parseQRCode(qrData);
    _activateSensorWithCode(sensorCode);
  }

  /// Publicar y reservar sensor (flujo definitivo)
  Future<void> _publishAndReserveSensor() async {
    await _controller.publishAndReserveSensor();
  }

  /// Confirmar activación del sensor (flujo definitivo)
  Future<void> _confirmSensor() async {
    await _controller.confirmSensor();
    widget.onSensorCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DefineSensorFlowContentWidget(
            formKey: _formKey,
            controller: _controller,
            warningMinController: _warningMinController,
            warningMaxController: _warningMaxController,
            alertMinController: _alertMinController,
            alertMaxController: _alertMaxController,
            onDefineSensor: _defineSensor,
            onActivateSensorWithCode: _activateSensorWithCode,
            onPublishAndReserveSensor: _publishAndReserveSensor,
            onConfirmSensor: _confirmSensor,
            onShowManualCodeDialog: _showManualCodeDialog,
            onOpenScanner: _openScanner,
            onHandleScannedQR: _handleScannedQR,
            onFinish: () => Navigator.of(context).pop(_controller.definedSensor),
          ),
        );
      },
    );
  }

}
