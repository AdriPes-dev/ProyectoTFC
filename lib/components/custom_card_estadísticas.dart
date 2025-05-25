import 'package:fichi/screens/pantallaverestadisticas.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartelEstadisticas extends StatelessWidget {
  final String dniEmpleado;

  const CartelEstadisticas({super.key, required this.dniEmpleado});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;

    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerTodasLasEstadisticas(dniEmpleado),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading(context);
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.length != 3) {
            return const Text("No se encontraron estadísticas.");
          }

          final statsSemanal = snapshot.data![0];
          final statsMensual = snapshot.data![1];
          final statsTotal = snapshot.data![2];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EstadisticasScreen(
                    diasTrabajados: statsSemanal['diasTrabajados'],
                    totalDias: 7,
                    dias: statsSemanal['dias'] ?? List.filled(7, false),
                    horasSemanales: statsSemanal['totalHoras'],
                    horasMensuales: statsMensual['totalHoras'],
                    horasTotales: statsTotal['totalHoras'],
                    incidenciasSemanales: statsSemanal['incidencias'],
                    incidenciasMensuales: statsMensual['incidencias'],
                    incidenciasTotales: statsTotal['incidencias'],
                  ),
                ),
              );
            },
            child: _buildCardEstadisticas(
              context,
              shadowColor,
              statsSemanal['totalHoras'],
              statsSemanal['diasTrabajados'],
              statsSemanal['incidencias'],
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerTodasLasEstadisticas(String dniEmpleado) async {
    final semanal = await FirebaseService().obtenerEstadisticasFichajesUltimaSemana(dniEmpleado);
    final mensual = await FirebaseService().obtenerEstadisticasFichajesUltimoMes(dniEmpleado);
    final total = await FirebaseService().obtenerEstadisticasFichajes(dniEmpleado);
    return [semanal, mensual, total];
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[600]!
          : Colors.grey[100]!,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                    ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardEstadisticas(
  BuildContext context, 
  Color shadowColor, 
  double horas, 
  int dias, 
  int incidencias
) {
  return Card(
    elevation: 0, // Quitamos la sombra predeterminada del Card
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Estadísticas Semanales",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Horas Totales:"),
                Text("${horas.toStringAsFixed(1)} h"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Días trabajados:"),
                Text("$dias"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Incidencias:"),
                Text("$incidencias"),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}