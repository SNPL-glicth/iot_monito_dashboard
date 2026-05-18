import 'package:flutter/material.dart';

/// Header con contadores estilo trading dashboard.
class WarningCountersHeader extends StatelessWidget {
  const WarningCountersHeader({
    super.key,
    required this.totalActive,
    required this.criticalCount,
    required this.warningCount,
  });

  final int totalActive;
  final int criticalCount;
  final int warningCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _buildCounterChip(
            label: 'ACTIVAS',
            count: totalActive,
            color: Colors.tealAccent,
            icon: Icons.notifications_active,
          ),
          const SizedBox(width: 12),
          _buildCounterChip(
            label: 'CRÍTICAS',
            count: criticalCount,
            color: Colors.redAccent,
            icon: Icons.error,
          ),
          const SizedBox(width: 12),
          _buildCounterChip(
            label: 'WARNINGS',
            count: warningCount,
            color: Colors.orangeAccent,
            icon: Icons.warning,
          ),
          const Spacer(),
          Text(
            'Por sensor',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterChip({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
