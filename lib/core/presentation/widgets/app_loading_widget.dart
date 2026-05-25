import 'package:flutter/material.dart';

/// Widget de carga estandarizado para toda la aplicación.
///
/// Usa [CircularProgressIndicator] con el color primario del tema
/// y un mensaje opcional debajo. Reemplaza implementaciones
/// dispares de loading por módulo.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
