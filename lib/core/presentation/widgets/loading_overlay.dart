import 'package:flutter/material.dart';

/// Overlay de pantalla completa para operaciones bloqueantes.
///
/// Muestra un indicador de progreso centrado con fondo semitransparente.
/// Útil para formularios y acciones que requieren espera obligatoria.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.isLoading = false,
    this.message,
    required this.child,
  });

  final bool isLoading;
  final String? message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AbsorbPointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
