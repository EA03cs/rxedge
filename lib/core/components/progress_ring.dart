import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// RxEdge Circular Progress Ring
///
/// Features:
/// - Clean stroke, strictly flat
/// - Primary deep teal progress arc with muted background track
/// - Optional center text/widget showing percentage or icon
class ProgressRing extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Widget? center;
  final Color? color;
  final Color? trackColor;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 52.0,
    this.strokeWidth = 4.0,
    this.center,
    this.color,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.rxColors;
    final textTheme = Theme.of(context).textTheme;

    final progressColor = color ?? colors.primary;
    final backgroundTrack = trackColor ?? colors.surfaceMuted;
    final clampedValue = value.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: clampedValue,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: backgroundTrack,
            ),
          ),
          if (center != null)
            center!
          else
            Text(
              '${(clampedValue * 100).toInt()}%',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                fontSize: size > 48 ? 12.0 : 10.0,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Track paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress paint
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
