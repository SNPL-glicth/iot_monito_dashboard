import 'package:flutter/material.dart';

/// Indicador de estado (en vivo / congelado) para el optimized realtime chart.
class OptimizedRealtimeChartStatus extends StatelessWidget {
  const OptimizedRealtimeChartStatus({super.key, required this.isFrozen});

  final bool isFrozen;

  @override
  Widget build(BuildContext context) {
    final color = isFrozen ? Colors.blueAccent : Colors.greenAccent;
    final label = isFrozen ? 'CONGELADO' : 'EN VIVO';
    final icon = isFrozen ? Icons.lock_clock : Icons.circle;

    return Row(
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
