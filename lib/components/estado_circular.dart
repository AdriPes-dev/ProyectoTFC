import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fichi/theme/appcolors.dart';

class EstadoCircularHoras extends StatefulWidget {
  final double horasTrabajadas;
  final double horasTotales;

  const EstadoCircularHoras({
    super.key,
    required this.horasTrabajadas,
    required this.horasTotales,
  });

  @override
  State<EstadoCircularHoras> createState() => _EstadoCircularState();
}

class _EstadoCircularState extends State<EstadoCircularHoras> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> arcAnimation;
  late Animation<double> horasAnimation;
  late double porcentaje;

  final double maxArc = math.pi;

  @override
  void initState() {
    super.initState();

    porcentaje = (widget.horasTotales > 0)
        ? (widget.horasTrabajadas / widget.horasTotales).clamp(0.0, 1.0)
        : 0.0;

    animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOutCubic,
    );

    arcAnimation = Tween<double>(
      begin: 0,
      end: maxArc * porcentaje,
    ).animate(curvedAnimation);

    horasAnimation = Tween<double>(
      begin: 0,
      end: widget.horasTrabajadas,
    ).animate(curvedAnimation);

    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        final horasAnimadas = horasAnimation.value;

        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(300, 300),
                painter: ProgressArc(maxArc, Colors.black54, false),
              ),
              CustomPaint(
                size: const Size(300, 300),
                painter: ProgressArc(arcAnimation.value, AppColors.primaryBlue, true),
              ),
              Text(
                '${horasAnimadas.toInt()}h/${widget.horasTotales.toInt()}h',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProgressArc extends CustomPainter {
  final double arc;
  final Color progressColor;
  final bool isBackground;

  ProgressArc(this.arc, this.progressColor, this.isBackground);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, 300, 300);
    const startAngle = -math.pi;
    final sweepAngle = arc;
    const useCenter = false;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    if (isBackground) {
      paint.shader = AppColors.mainGradient.createShader(rect);
    }

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EstadoCircularIncidencias extends StatefulWidget {
  final int incidencias;

  const EstadoCircularIncidencias({
    super.key,
    required this.incidencias,
  });

  @override
  State<EstadoCircularIncidencias> createState() => _EstadoCircularIncidenciasState();
}

class _EstadoCircularIncidenciasState extends State<EstadoCircularIncidencias> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> arcAnimation;
  late Animation<double> incidenciasAnimation;

  final double totalHoras = 40;
  final double maxArc = math.pi;

  @override
  void initState() {
    super.initState();

    final porcentaje = (widget.incidencias / totalHoras).clamp(0.0, 1.0);

    animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    final curved = CurvedAnimation(parent: animController, curve: Curves.easeInOutCubic);

    arcAnimation = Tween<double>(
      begin: 0,
      end: maxArc * porcentaje,
    ).animate(curved);

    incidenciasAnimation = Tween<double>(
      begin: 0,
      end: widget.incidencias.toDouble(),
    ).animate(curved);

    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Color getColorPorIncidencias(int incidencias, double porcentaje) {
    if (incidencias <= 1) return Colors.green;
    return Color.lerp(Colors.yellow, Colors.red, porcentaje)!;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        final incidencias = incidenciasAnimation.value.toInt();
        final porcentaje = (widget.incidencias / totalHoras).clamp(0.0, 1.0);
        final color = getColorPorIncidencias(widget.incidencias, porcentaje);

        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(80, 80),
                painter: ProgressArcIncidencias(math.pi, Colors.black12),
              ),
              if (widget.incidencias > 0)
                CustomPaint(
                  size: const Size(80, 80),
                  painter: ColoredProgressArc(arcAnimation.value, color),
                ),
              Text(
                '$incidencias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProgressArcIncidencias extends CustomPainter {
  final double arc;
  final Color color;

  ProgressArcIncidencias(this.arc, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -math.pi;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawArc(rect.deflate(10), startAngle, arc, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ColoredProgressArc extends CustomPainter {
  final double arc;
  final Color color;

  ColoredProgressArc(this.arc, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -math.pi;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawArc(rect.deflate(10), startAngle, arc, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}