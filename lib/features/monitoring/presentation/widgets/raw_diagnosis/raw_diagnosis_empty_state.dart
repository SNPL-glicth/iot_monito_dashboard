import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


class RawDiagnosisEmptyState extends StatelessWidget {
  const RawDiagnosisEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          SizedBox(height: DesignSpacing.lg),
          Text('Sin lecturas', style: DesignTextStyles.cardTitle),
          SizedBox(height: DesignSpacing.sm),
          Text('No hay datos para este sensor aún.', style: DesignTextStyles.bodyText),
        ],
      ),
    );
  }
}
