import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/pantalla_registrar_incidencia.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';

class WidgetIncidencia extends StatelessWidget {
  final Persona p;

  const WidgetIncidencia({
    super.key,
    required this.p,
  });

  @override
Widget build(BuildContext context) {
  final cardColor = Theme.of(context).cardColor; 

  return GestureDetector(
  onTap: () {

    if (p.empresaCif != null && p.empresaCif!.isNotEmpty) {
           Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistrarIncidencia(persona: p)),
    );
          } else {
           CustomSnackbar.mostrar(
              context,
              'Se necesita una empresa para registrar incidencias',
              icono: Icons.warning_amber_rounded,
              texto: Colors.orange,
            );
          }
    
  },
  child: Card(
  elevation: 0, // Quitamos la sombra por defecto
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
          offset: Offset(0, 4), // sombra azul por todos lados
        ),
      ],
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 50, color: AppColors.primaryBlue),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 8),
              Text(
                "Registrar Incidencia",
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
            ],
          ),
        ],
      ),
    ),
  ),
),
);
}
}
