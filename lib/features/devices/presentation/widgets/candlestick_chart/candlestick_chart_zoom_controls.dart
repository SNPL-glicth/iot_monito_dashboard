import 'package:flutter/material.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Controles de zoom para el candlestick chart.
class CandlestickChartZoomControls extends StatelessWidget {
  const CandlestickChartZoomControls({
    super.key,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${(zoomLevel * 100).toInt()}%',
            style: const TextStyle(
              color: DesignColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8),
        _ZoomButton(
          icon: Icons.remove,
          onPressed: zoomLevel > minZoom ? onZoomOut : null,
          tooltip: 'Alejar',
        ),
        SizedBox(width: 4),
        _ZoomButton(
          icon: Icons.add,
          onPressed: zoomLevel < maxZoom ? onZoomIn : null,
          tooltip: 'Acercar',
        ),
        SizedBox(width: 4),
        _ZoomButton(
          icon: Icons.fit_screen,
          onPressed: zoomLevel != 1.0 ? onReset : null,
          tooltip: 'Restablecer',
        ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: onPressed != null
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 16,
              color: onPressed != null ? DesignColors.textPrimary : Colors.white30,
            ),
          ),
        ),
      ),
    );
  }
}
