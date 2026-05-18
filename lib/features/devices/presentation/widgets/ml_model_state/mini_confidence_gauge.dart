import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mini medidor de confianza para vista compacta.
class MiniConfidenceGauge extends StatelessWidget {
  const MiniConfidenceGauge({
    super.key,
    required this.confidence,
    required this.color,
  });

  final double confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniGaugePainter(
        confidence: confidence,
        color: color,
      ),
      child: Center(
        child: Text(
          '${(confidence * 100).toInt()}',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MiniGaugePainter extends CustomPainter {
  _MiniGaugePainter({
    required this.confidence,
    required this.color,
  });

  final double confidence;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 2;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5 * confidence,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniGaugePainter oldDelegate) {
    return oldDelegate.confidence != confidence || oldDelegate.color != color;
  }
}
