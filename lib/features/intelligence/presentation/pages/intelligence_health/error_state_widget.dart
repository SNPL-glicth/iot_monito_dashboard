import 'package:flutter/material.dart';

import '../../widgets/intelligence_health_widgets.dart';

/// Error state widget for intelligence health page
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
  });

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return IntelligenceHealthWidgets.errorState(errorMessage);
  }
}
