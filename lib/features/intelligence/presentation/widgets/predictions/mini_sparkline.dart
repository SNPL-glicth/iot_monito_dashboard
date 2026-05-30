import 'package:flutter/material.dart';

import '../../../../../core/theme/zenin_colors.dart';

/// Mini sparkline dibujado con CustomPainter.
///
/// Solo pinta; no accede a ViewModels.
class MiniSparklineWidget extends StatelessWidget {
  const MiniSparklineWidget({
    super.key,
    required this.values,
    required this.lineColor,
  });

  final List<double> values;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 44,
      child: CustomPaint(
        painter: _MiniSparklinePainter(
          values: values,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  _MiniSparklinePainter({
    required this.values,
    required this.lineColor,
  });

  final List<double> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || values.length < 2) {
      _drawNoDataLine(canvas, size);
      return;
    }

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal == minVal ? 1.0 : maxVal - minVal;

    final stepX = size.width / (values.length - 1);

    final path = Path();
    final fillPath = Path();

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - ((values[i] - minVal) / range) * size.height;
      points.add(Offset(x, y));
    }

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final control1 = Offset((p0.dx + mid.dx) / 2, p0.dy);
      final control2 = Offset((mid.dx + p1.dx) / 2, p1.dy);

      path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, p1.dx, p1.dy);
      fillPath.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    // Fill semitransparente
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = lineColor.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    // Línea
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawNoDataLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZeninColors.border
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashWidth = 4.0;
    final dashSpace = 4.0;
    final y = size.height / 2;
    var x = 0.0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + dashWidth, y),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
