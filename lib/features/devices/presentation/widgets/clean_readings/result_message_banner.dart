import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Banner con mensaje de resultado (éxito o error).
class ResultMessageBanner extends StatelessWidget {
  const ResultMessageBanner({super.key, required this.message});

  final String message;

  bool get _isError => message.contains('Error');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isError ? DesignColors.red.withValues(alpha: 0.15) : DesignColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(
          color: _isError
              ? DesignColors.red.withValues(alpha: 0.3)
              : DesignColors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: _isError ? DesignColors.red : DesignColors.green,
            size: 20,
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _isError ? DesignColors.red : DesignColors.green,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
