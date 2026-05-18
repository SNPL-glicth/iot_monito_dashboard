import 'package:flutter/material.dart';

/// Helpers de formateo y widgets auxiliares para AlertsHubPage
class AlertsHubHelpers {
  static int severityRank(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 0;
      case 'warning':
        return 1;
      case 'info':
      case 'notice':
        return 2;
      default:
        return 3;
    }
  }

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'info':
      case 'notice':
        return Colors.lightBlueAccent;
      default:
        return Colors.blueGrey;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  static Widget buildStatusBadge(String status, Color severityColor) {
    final statusLower = status.toLowerCase();

    Color bgColor;
    Color textColor;
    IconData? icon;
    String label;

    switch (statusLower) {
      case 'acknowledged':
        bgColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        icon = Icons.check_circle;
        label = 'ATENDIDA';
        break;
      case 'resolved':
        bgColor = Colors.blueGrey.withValues(alpha: 0.2);
        textColor = Colors.blueGrey;
        icon = Icons.done_all;
        label = 'RESUELTA';
        break;
      case 'active':
      default:
        bgColor = severityColor.withValues(alpha: 0.2);
        textColor = severityColor;
        icon = null;
        label = 'ACTIVA';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar el contador de alertas por tipo
class AlertCountChip extends StatelessWidget {
  const AlertCountChip({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
