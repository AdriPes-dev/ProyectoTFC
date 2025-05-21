import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/pantallaregistrarincidencia.dart';
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
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final shadowColor = isDarkMode ? Colors.white : Colors.black;
  final cardColor = Theme.of(context).cardColor; 

  return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistrarIncidencia(persona: p)),
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
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
