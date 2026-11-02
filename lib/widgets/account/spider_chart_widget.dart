import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:torre_de_cartas_movil/widgets/theme/app_colors.dart';

class SpiderChartAxis {
  final String label;
  final double value; // 0.0 to 1.0
  final String displayValue;

  const SpiderChartAxis({
    required this.label,
    required this.value,
    required this.displayValue,
  });
}

class SpiderChartWidget extends StatelessWidget {
  final List<SpiderChartAxis> axes;
  final double size;

  const SpiderChartWidget({
    super.key,
    required this.axes,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    if (axes.length < 3) {
      return const SizedBox();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              size: Size(size, size),
              painter: _SpiderChartPainter(
                axes: axes,
                animationProgress: animValue,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpiderChartPainter extends CustomPainter {
  final List<SpiderChartAxis> axes;
  final double animationProgress;

  _SpiderChartPainter({
    required this.axes,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 38;
    final n = axes.length;
    final angleStep = (2 * math.pi) / n;
    // Empezamos apuntando hacia arriba (-pi / 2)
    const startAngle = -math.pi / 2;

    // 1. Dibujar redes concéntricas (niveles 20%, 40%, 60%, 80%, 100%)
    final gridPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisLinePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const levels = [0.2, 0.4, 0.6, 0.8, 1.0];
    for (final level in levels) {
      final levelRadius = radius * level;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + levelRadius * math.cos(angle);
        final y = center.dy + levelRadius * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Dibujar radios (ejes) desde el centro hacia cada vértice
    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisLinePaint);
    }

    // 3. Dibujar el polígono de datos del jugador
    final dataPath = Path();
    final points = <Offset>[];

    for (int i = 0; i < n; i++) {
      final clampedValue = axes[i].value.clamp(0.08, 1.0);
      final valRadius = radius * clampedValue * animationProgress;
      final angle = startAngle + i * angleStep;
      final x = center.dx + valRadius * math.cos(angle);
      final y = center.dy + valRadius * math.sin(angle);
      final pt = Offset(x, y);
      points.add(pt);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Relleno suave con tinte dorado
    final fillPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Borde resaltado del polígono
    final strokePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, strokePaint);

    // 4. Puntos (vértices) del polígono de datos
    final pointFillPaint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.2, pointFillPaint);
      canvas.drawCircle(pt, 4.2, pointStrokePaint);
    }

    // 5. Etiquetas de cada eje con valor
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final angle = startAngle + i * angleStep;
      final labelRadius = radius + 22;
      final lx = center.dx + labelRadius * math.cos(angle);
      final ly = center.dy + labelRadius * math.sin(angle);

      final labelSpan = TextSpan(
        children: [
          TextSpan(
            text: '${axes[i].label}\n',
            style: GoogleFonts.cinzel(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          TextSpan(
            text: axes[i].displayValue,
            style: GoogleFonts.sourceSans3(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      );

      textPainter.text = labelSpan;
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();

      final textOffset = Offset(
        lx - textPainter.width / 2,
        ly - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _SpiderChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.axes != axes;
  }
}
