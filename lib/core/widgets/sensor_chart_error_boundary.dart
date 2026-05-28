import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Error boundary para widgets de graficas de sensores.
///
/// Captura errores de renderizado de charts y muestra un estado
/// de "datos invalidos" en lugar de crashear la aplicacion.
///
/// Uso:
/// ```dart
/// SensorChartErrorBoundary(
///   sensorId: '42',
///   child: MyChartWidget(...),
/// )
/// ```
class SensorChartErrorBoundary extends StatefulWidget {
  const SensorChartErrorBoundary({
    super.key,
    required this.child,
    this.sensorId,
    this.onRetry,
  });

  final Widget child;
  final String? sensorId;
  final VoidCallback? onRetry;

  @override
  State<SensorChartErrorBoundary> createState() => _SensorChartErrorBoundaryState();
}

class _SensorChartErrorBoundaryState extends State<SensorChartErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorView(context);
    }
    return widget.child;
  }

  Widget _buildErrorView(BuildContext context) {
    final isDebug = !kReleaseMode;

    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.white30,
            ),
            const SizedBox(height: 12),
            const Text(
              'Datos del sensor no disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${widget.sensorId ?? "desconocido"}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            if (isDebug && _error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: $_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (widget.onRetry != null)
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }

  void _resetError() {
    if (mounted) {
      setState(() {
        _error = null;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SensorChartErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error when sensorId changes
    if (oldWidget.sensorId != widget.sensorId) {
      _resetError();
    }
  }
}

/// Extension para usar SensorChartErrorBoundary facilmente en arboles de widgets.
extension SensorChartErrorBoundaryX on Widget {
  Widget withSensorChartErrorBoundary({
    String? sensorId,
    VoidCallback? onRetry,
  }) {
    return SensorChartErrorBoundary(
      sensorId: sensorId,
      onRetry: onRetry,
      child: this,
    );
  }
}
