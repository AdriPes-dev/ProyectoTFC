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
      child: FutureBuilder<Map<String, dynamic>>(
        future: FirebaseService().obtenerEstadisticasFichajesUltimaSemana(dniEmpleado),
        builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
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


          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("No se encontraron estadísticas.");
          }

          final stats = snapshot.data!;
          final horas = stats['totalHoras'];
          final dias = stats['diasTrabajados'];
          final incidencias = stats['incidencias'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EstadisticasSemanalesScreen(
                    horasTrabajadas: horas,
                    horasTotales: 40,
                    diasTrabajados: dias,
                    totalDias: 7,
                    dias: stats['dias'] ?? List.filled(7, false),
                    numeroIncidencias: incidencias,
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: shadowColor,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
            ),
          );
        },
      ),
    );
  }
}