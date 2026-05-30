import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Sección de umbral (warning o alert) con inputs min/max.
class ThresholdSection extends StatelessWidget {
  const ThresholdSection({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.minController,
    required this.maxController,
    required this.unit,
  });

  final String title;
  final Color color;
  final IconData icon;
  final TextEditingController minController;
  final TextEditingController maxController;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: minController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Mínimo',
                    suffixText: unit,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: maxController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Máximo',
                    suffixText: unit,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignRadius.sm),
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
