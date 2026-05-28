import 'package:flutter/material.dart';

class ErrorBannerConfig {
  const ErrorBannerConfig({
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  factory ErrorBannerConfig.networkError(BuildContext context) {
    return ErrorBannerConfig(
      message: 'No connection. Showing last known data.',
      onRetry: null,
      onDismiss: null,
    );
  }

  factory ErrorBannerConfig.serverError(BuildContext context) {
    return ErrorBannerConfig(
      message: 'Service unavailable. Please try again later.',
      onRetry: null,
      onDismiss: null,
    );
  }
}
