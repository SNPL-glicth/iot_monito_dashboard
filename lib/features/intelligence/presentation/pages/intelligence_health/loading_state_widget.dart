import 'package:flutter/material.dart';
import '../../../../../core/theme/design_colors.dart';

/// Loading state widget for intelligence health page
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando diagnóstico del modelo...',
            style: TextStyle(color: DesignColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
