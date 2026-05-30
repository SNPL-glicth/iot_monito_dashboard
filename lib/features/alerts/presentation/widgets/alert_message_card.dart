import 'package:flutter/material.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Tarjeta de mensaje adicional de una alerta
class AlertMessageCard extends StatelessWidget {
  const AlertMessageCard({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blueAccent),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  'Información adicional',
                  style: DesignTextStyles.cardTitle,
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              message,
              style: DesignTextStyles.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}
