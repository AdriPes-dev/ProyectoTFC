import 'package:fichi/screens/pantallaregistraractividad.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';

class RegistrarActividad extends StatelessWidget {
  const RegistrarActividad({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white54 : Colors.black26;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaRegistrarActividad()));
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

