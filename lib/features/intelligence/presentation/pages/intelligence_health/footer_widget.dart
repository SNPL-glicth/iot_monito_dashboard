import 'package:flutter/material.dart';
import '../../widgets/intelligence_health_helpers.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Footer widget showing diagnostic timestamp
class FooterWidget extends StatelessWidget {
  const FooterWidget({
    super.key,
    required this.timestamp,
  });

  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Diagnóstico generado: ${IntelligenceHealthHelpers.formatDateTime(timestamp)}',
        style: DesignTextStyles.bodyText.copyWith(fontSize: 11),
      ),
    );
  }
}
