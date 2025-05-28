import 'package:flutter/material.dart';
import 'package:fichi/components/bordes_degradados.dart';
import 'package:fichi/theme/appcolors.dart';

class CustomSnackbar {
  static void mostrar(
    BuildContext context,
    String mensaje, {
    IconData icono = Icons.info_outline,
    Duration duracion = const Duration(seconds: 3),
    Color? fondo,
    Color? texto,
    bool centrado = true,
  }) {
    final overlay = Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = fondo ?? (isDark ? Colors.black : Colors.white);
    final textColor = texto ?? (isDark ? Colors.white : Colors.black87);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              shape: GradientBoxBorder(
                gradient: AppColors.mainGradient,
                width: 2.0,
              ),
              color: backgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: centrado ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icono, color: textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mensaje,
                    style: TextStyle(color: textColor),
                    textAlign: centrado ? TextAlign.center : TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duracion, () {
      overlayEntry.remove();
    });
  }
}