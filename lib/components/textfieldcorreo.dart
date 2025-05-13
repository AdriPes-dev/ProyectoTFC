import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';

class TextFormCorreo extends StatefulWidget {
  final TextEditingController controller;
  const TextFormCorreo({super.key, required this.controller});

  @override
  State<TextFormCorreo> createState() => _TextFormCorreoState();
}

class _TextFormCorreoState extends State<TextFormCorreo> {
  final FocusNode _focusNode = FocusNode(); // Controla el estado de foco

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Actualiza la UI cuando el foco cambia
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Libera el recurso
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(2), // Grosor del borde
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Borde gris si no está enfocado, degradado si sí
          border: _focusNode.hasFocus
              ? GradientBoxBorder( // Borde degradado al enfocar
                  gradient: AppColors.mainGradient,
                  width: 2.0,
                )
              : Border.all(color: Colors.grey, width: 1.5), // Gris por defecto
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode, // Asigna el FocusNode
          decoration: InputDecoration(
            labelText: "Introduce tu correo electrónico",
            filled: true,
            fillColor: Colors.white, // Fondo blanco
            border: InputBorder.none, // Elimina el borde interno
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(Icons.mail, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}