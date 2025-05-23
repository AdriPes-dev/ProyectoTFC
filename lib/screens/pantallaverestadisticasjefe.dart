import 'dart:math' as math;

import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';

class PantallaEstadisticasEmpleados extends StatelessWidget {
  final Persona ceo;
  final List<Persona> empleados;

  const PantallaEstadisticasEmpleados({
    super.key,
    required this.ceo,
    required this.empleados,
  });

  Future<Map<String, dynamic>> obtenerEstadisticas(String dniEmpleado) async {
    return await FirebaseService().obtenerEstadisticasFichajesUltimaSemana(dniEmpleado);
  }

  Widget _buildEstadisticaCard(Persona persona, Map<String, dynamic> datos) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de texto (izquierda)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${persona.nombre} ${persona.apellidos}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Días trabajados: ${datos['diasTrabajados']}'),
                  Text('Incidencias: ${datos['incidencias']}'),
                ],
              ),
            ),
            // Widget circular compacto (derecha)
            MiniEstadoCircularHoras(
              horasTrabajadas: datos['totalHoras'],
              horasTotales: 40.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaConEstadisticas(Persona persona) {
    return FutureBuilder<Map<String, dynamic>>(
      future: obtenerEstadisticas(persona.dni),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return ListTile(
            title: Text('${persona.nombre} ${persona.apellidos}'),
            subtitle: const Text('Error al cargar estadísticas'),
          );
        }

        final datos = snapshot.data ?? {};
        return _buildEstadisticaCard(persona, datos);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de empleados'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tú',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildPersonaConEstadisticas(ceo),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Text(
              'Empleados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...empleados.map((empleado) => _buildPersonaConEstadisticas(empleado)).toList(),
        ],
      ),
    );
  }
}

class MiniEstadoCircularHoras extends StatefulWidget {
  final double horasTrabajadas;
  final double horasTotales;

  const MiniEstadoCircularHoras({
    super.key,
    required this.horasTrabajadas,
    required this.horasTotales,
  });

  @override
  State<MiniEstadoCircularHoras> createState() => _MiniEstadoCircularHorasState();
}

class _MiniEstadoCircularHorasState extends State<MiniEstadoCircularHoras>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double porcentajeFinal;

  @override
  void initState() {
    super.initState();
    porcentajeFinal = (widget.horasTotales > 0)
        ? (widget.horasTrabajadas / widget.horasTotales).clamp(0.0, 1.0)
        : 0.0;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.0, end: porcentajeFinal).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rect = Rect.fromLTWH(0, 0, 80, 80);

    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final arc = math.pi * _animation.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(80, 80),
                painter: _MiniProgressArc(
                  arc: math.pi,
                  color: Colors.black12,
                  isGradient: false,
                ),
              ),
              CustomPaint(
                size: const Size(80, 80),
                painter: _MiniProgressArc(
                  arc: arc,
                  color: AppColors.primaryBlue,
                  isGradient: true,
                  gradientRect: rect,
                ),
              ),
              Text(
                '${widget.horasTrabajadas.toInt()}h',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniProgressArc extends CustomPainter {
  final double arc;
  final Color color;
  final bool isGradient;
  final Rect? gradientRect;

  _MiniProgressArc({
    required this.arc,
    required this.color,
    required this.isGradient,
    this.gradientRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi;
    const useCenter = false;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = color;

    if (isGradient && gradientRect != null) {
      paint.shader = AppColors.mainGradient.createShader(gradientRect!);
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, startAngle, arc, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
