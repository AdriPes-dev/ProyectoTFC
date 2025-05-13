import 'package:fichi/components/custom_card_actividad.dart';
import 'package:fichi/components/custom_card_estad%C3%ADsticas.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Parte superior: TimeTracker
          TimeTracker(),

          const SizedBox(height: 16),

          // Parte inferior
          Expanded(
            child: Row(
              children: [
                // Bloque izquierdo - Incidencia
                WidgetIncidencia(),

                const SizedBox(width: 16),

                // Bloque derecho
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Registrar Actividad
                      RegistrarActividad(),

                      const SizedBox(height: 16),

                      // Ver Estadísticas
                      CartelEstadisticas(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

