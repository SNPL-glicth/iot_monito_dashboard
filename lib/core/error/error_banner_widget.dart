import 'package:flutter/material.dart';
import 'error_banner_config.dart';
import '../../core/theme/design_spacing.dart';

class ErrorBannerWidget extends StatelessWidget {
  const ErrorBannerWidget({
    required this.config,
    super.key,
  });

  final ErrorBannerConfig config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: config.message,
      child: Container(
        color: colorScheme.error,
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.onError,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                config.message,
                style: TextStyle(color: colorScheme.onError),
              ),
            ),
            if (config.onRetry != null)
              Semantics(
                button: true,
                child: TextButton(
                  onPressed: config.onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ),
            if (config.onDismiss != null)
              Semantics(
                button: true,
                child: TextButton(
                  onPressed: config.onDismiss,
                  child: Text(
                    'Dismiss',
                    style: TextStyle(color: colorScheme.onError),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
