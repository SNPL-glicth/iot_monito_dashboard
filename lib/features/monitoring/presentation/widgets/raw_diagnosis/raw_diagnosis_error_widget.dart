import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


class RawDiagnosisErrorWidget extends StatelessWidget {
  const RawDiagnosisErrorWidget({
    super.key,
    required this.statusCode,
    required this.message,
    required this.onRetry,
  });

  final int? statusCode;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DesignColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DesignRadius.md),
              ),
              child: Icon(Icons.error_outline, size: 40, color: DesignColors.red),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text('Error al cargar datos', style: DesignTextStyles.cardTitle),
            SizedBox(height: DesignSpacing.sm),
            if (statusCode != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                decoration: BoxDecoration(
                  color: DesignColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                  border: Border.all(color: DesignColors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'HTTP $statusCode',
                  style: TextStyle(color: DesignColors.red, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            SizedBox(height: DesignSpacing.md),
            Text(message, style: DesignTextStyles.bodyText, textAlign: TextAlign.center),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.cyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
