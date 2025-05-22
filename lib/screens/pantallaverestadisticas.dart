import 'package:fichi/components/estado_circular.dart';
import 'package:flutter/material.dart';

class EstadisticasSemanalesScreen extends StatefulWidget {
  final int diasTrabajados;
  final int totalDias;
  final List<bool> dias;
  final double horasTrabajadas;
  final double horasTotales;
  final int numeroIncidencias;

  const EstadisticasSemanalesScreen({
    super.key,
    required this.diasTrabajados,
    required this.totalDias,
    required this.dias,
    required this.horasTrabajadas,
    required this.horasTotales,
    required this.numeroIncidencias,
  });

  @override
  State<EstadisticasSemanalesScreen> createState() => _EstadisticasSemanalesScreenState();
}

class _EstadisticasSemanalesScreenState extends State<EstadisticasSemanalesScreen> with SingleTickerProviderStateMixin {

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
      appBar: AppBar(title: const Text("Estadísticas")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Estadísticas de esta semana",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
            SizedBox(height: 60),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Horas trabajadas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                EstadoCircularHoras(horasTrabajadas: widget.horasTrabajadas,horasTotales: widget.horasTotales,),
                const SizedBox(height: 10),
                const Text("Días trabajados", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _buildDiasTrabajadosRow(),
                const SizedBox(height: 40),
                    const Text("Incidencias que has registrado", style: TextStyle(fontSize: 18)),

                EstadoCircularIncidencias(incidencias: widget.numeroIncidencias),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
