import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:muslim_guide/app/theme/app_colors.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Interactive compass dial for the Qibla screen.
///
/// The ring is fixed on screen (top of the dial = top of the device) and
/// the green arrow rotates by [relativeAngle] so it points at the Kaaba.
class QiblaCompass extends StatelessWidget {
  /// Creates the compass widget.
  const new({
    required this.relativeAngle,
    this.deviceHeading,
    super.key,
  });

  /// Dial rotation `(bearing − heading) mod 360` in `[0, 360)`.
  final double relativeAngle;

  /// Current device heading `[0, 360)`, for numeric display upstream.
  final double? deviceHeading;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          '${localizations.qibla_direction_label}: '
          '${relativeAngle.toStringAsFixed(0)}°',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortest = constraints.biggest.shortestSide;
          final side = (shortest.isFinite ? shortest : 300) * 0.85;
          return Center(
            child: SizedBox.square(
              dimension: side,
              child: CustomPaint(
                painter: _QiblaCompassPainter(
                  relativeAngle: relativeAngle,
                  primary: colorScheme.primary,
                  onSurface: colorScheme.onSurface,
                  surface: colorScheme.surface,
                  errorColor: AppColors.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QiblaCompassPainter extends CustomPainter {
  const new({
    required this.relativeAngle,
    required this.primary,
    required this.onSurface,
    required this.surface,
    required this.errorColor,
  });

  final double relativeAngle;
  final Color primary;
  final Color onSurface;
  final Color surface;
  final Color errorColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    // Radial gradient background (Phase 02 hero pattern; qibla_bg
    // artwork is deferred — GAP-qibla-bg).
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              primary.withValues(alpha: 0.20),
              surface,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      )
      // Outer ring.
      ..drawCircle(
        center,
        radius * 0.96,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, radius * 0.02)
          ..color = primary,
      );

    _drawTicks(canvas, center, radius);
    _drawCardinals(canvas, center, radius);
    _drawTopMarker(canvas, center, radius);
    _drawArrow(canvas, center, radius);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.7)
      ..strokeWidth = math.max(1, radius * 0.012);
    for (var degree = 0; degree < 360; degree += 30) {
      final angle = (degree - 90) * math.pi / 180;
      final outer = Offset(
        center.dx + math.cos(angle) * radius * 0.94,
        center.dy + math.sin(angle) * radius * 0.94,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * radius * 0.86,
        center.dy + math.sin(angle) * radius * 0.86,
      );
      canvas.drawLine(inner, outer, tickPaint);

      // Degree numbers every 30° except the cardinal positions.
      if (degree % 90 != 0) {
        _drawCenteredText(
          canvas,
          text: '$degree',
          center: Offset(
            center.dx + math.cos(angle) * radius * 0.74,
            center.dy + math.sin(angle) * radius * 0.74,
          ),
          fontSize: radius * 0.11,
          color: onSurface.withValues(alpha: 0.8),
        );
      }
    }
  }

  void _drawCardinals(Canvas canvas, Offset center, double radius) {
    const labels = <int, String>{0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    labels.forEach((degree, label) {
      final angle = (degree - 90) * math.pi / 180;
      _drawCenteredText(
        canvas,
        text: label,
        center: Offset(
          center.dx + math.cos(angle) * radius * 0.74,
          center.dy + math.sin(angle) * radius * 0.74,
        ),
        fontSize: radius * 0.16,
        color: degree == 0 ? primary : onSurface,
        fontWeight: FontWeight.bold,
      );
    });
  }

  void _drawTopMarker(Canvas canvas, Offset center, double radius) {
    // Fixed marker: the top edge of the device (0° on the ring).
    final paint = Paint()
      ..color = errorColor
      ..strokeWidth = math.max(2, radius * 0.03)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.98),
      Offset(center.dx, center.dy - radius * 0.84),
      paint,
    );
    final triangle = Path()
      ..moveTo(center.dx, center.dy - radius * 0.82)
      ..lineTo(center.dx - radius * 0.07, center.dy - radius * 0.94)
      ..lineTo(center.dx + radius * 0.07, center.dy - radius * 0.94)
      ..close();
    canvas.drawPath(triangle, paint..style = PaintingStyle.fill);
  }

  void _drawArrow(Canvas canvas, Offset center, double radius) {
    // Arrow points at the Qibla relative to the device top.
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(relativeAngle * math.pi / 180);

    final arrowPaint = Paint()..color = primary;
    final path = Path()
      ..moveTo(0, -radius * 0.72) // Tip, pointing up.
      ..lineTo(-radius * 0.14, -radius * 0.34)
      ..lineTo(0, -radius * 0.44)
      ..lineTo(radius * 0.14, -radius * 0.34)
      ..close();
    canvas
      ..drawPath(path, arrowPaint)
      ..drawLine(
        Offset.zero,
        Offset(0, -radius * 0.40),
        Paint()
          ..color = primary
          ..strokeWidth = math.max(2, radius * 0.045)
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(
        Offset.zero,
        radius * 0.06,
        Paint()..color = primary,
      )
      ..restore();
  }

  void _drawCenteredText(
    Canvas canvas, {
    required String text,
    required Offset center,
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_QiblaCompassPainter oldDelegate) {
    return oldDelegate.relativeAngle != relativeAngle ||
        oldDelegate.primary != primary ||
        oldDelegate.onSurface != onSurface ||
        oldDelegate.surface != surface;
  }
}
