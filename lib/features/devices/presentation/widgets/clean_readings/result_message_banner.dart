import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';

/// Banner con mensaje de resultado (éxito o error).
class ResultMessageBanner extends StatelessWidget {
  const ResultMessageBanner({super.key, required this.message});

  final String message;

  bool get _isError => message.contains('Error');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isError ? DashboardColors.redAccent15 : DashboardColors.greenAccent15,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isError
              ? DashboardColors.error.withValues(alpha: 0.3)
              : DashboardColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: _isError ? DashboardColors.error : DashboardColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _isError ? DashboardColors.error : DashboardColors.success,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
