import 'package:fichi/screens/pantallaregistrarincidencia.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';

class WidgetIncidencia extends StatelessWidget {
  const WidgetIncidencia({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white54 : Colors.black26;
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistrarIncidencia()),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: shadowColor,
          child: Container(
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // centra verticalmente
                crossAxisAlignment: CrossAxisAlignment.center, // centra horizontalmente
                children:[
                  Icon(Icons.warning_amber_rounded, size: 50, color: AppColors.primaryBlue),
                  SizedBox(height: 8),
                  Text(
                    "Registrar Incidencia",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
