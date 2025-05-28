import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/pantalla_registrar_actividad.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';


class RegistrarActividad extends StatelessWidget {

  final Persona p;

  const RegistrarActividad({
    super.key,
    required this.p,
  });
  

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white54 : Colors.black;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (p.empresaCif != null && p.empresaCif!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CrearActividadScreen(persona: p),
              ),
            );
          } else {
           CustomSnackbar.mostrar(
                          context,
                          'Se necesita una empresa para registrar actividades',
                          icono: Icons.warning_amber_rounded,
                          texto: Colors.orange,
                        );
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: shadowColor,
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
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_calendar, size: 40, color: AppColors.primaryBlue),
                  const SizedBox(height: 8),
                  Text("Registrar Actividad", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

