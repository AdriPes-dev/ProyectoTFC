import 'package:fichi/components/custom_card_actividad.dart';
import 'package:fichi/components/custom_card_actividades.dart';
import 'package:fichi/components/custom_card_estadísticas.dart';
import 'package:fichi/components/custom_card_incidencia.dart';
import 'package:fichi/components/custom_card_tiempo.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:flutter/material.dart';

class PaginaPrincipal extends StatelessWidget {
  final Persona persona;

  const PaginaPrincipal({
    super.key,
    required this.persona,
  });

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Parte superior: TimeTracker
          TimeTracker(persona: persona,),

          const SizedBox(height: 16),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bloque izquierdo - Incidencia
                WidgetIncidencia(p: persona), // ¡Sin Expanded aquí!

                const SizedBox(width: 16),

                // Bloque derecho
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      RegistrarActividad(p: persona),
                      const SizedBox(height: 16),
                      CartelEstadisticas(),
                    ],
                  ),
                ),
              ],
            ),
          ),
           Padding(
             padding: const EdgeInsets.all(20.0),
             child: ActividadRecienteCard(p:persona),
           ),
           const SizedBox(height: 80),
        ],
      ),
    ),
  );
}

}
