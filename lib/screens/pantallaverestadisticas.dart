import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class EstadisticasSemanalesScreen extends StatefulWidget {
  final int diasTrabajados;
  final int totalDias;
  final List<bool> dias; // true = trabajado, false = no trabajado

  const EstadisticasSemanalesScreen({
    super.key,
    required this.diasTrabajados,
    required this.totalDias,
    required this.dias,
  });

  @override
  State<EstadisticasSemanalesScreen> createState() => _EstadisticasSemanalesScreenState();
}

class _EstadisticasSemanalesScreenState extends State<EstadisticasSemanalesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final porcentaje = widget.diasTrabajados / widget.totalDias;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: porcentaje).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDiasTrabajadosRow() {
  const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(widget.dias.length, (index) {
      final trabajado = widget.dias[index];
      final letra = diasSemana[index % 7];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: trabajado ? Colors.green : Colors.red,
          child: Text(
            letra,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas Semanales")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 12.0,
                  percent: _animation.value.clamp(0.0, 1.0),
                  center: Text(
                    "${widget.diasTrabajados}/${widget.totalDias}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  progressColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                );
              },
            ),
            const SizedBox(height: 32),
            const Text("Días trabajados", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            _buildDiasTrabajadosRow(),
          ],
        ),
      ),
    );
  }
}
