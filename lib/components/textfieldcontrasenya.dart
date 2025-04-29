import 'package:fichi/components/bordesdegradados.dart';
import 'package:flutter/material.dart';

class TextFormContrasenya extends StatefulWidget {
  const TextFormContrasenya({super.key});

  @override
  State<TextFormContrasenya> createState() => _EstadosContrasenya();
}

class _EstadosContrasenya extends State<TextFormContrasenya> {
  bool _estadoContrasenya = false;
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        // Borde gris si no está enfocado, degradado si sí
        border: _focusNode.hasFocus
            ? GradientBoxBorder( // Usa tu clase personalizada
                gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                width: 2.0,
              )
            : Border.all(color: Colors.grey, width: 1.5), // Gris por defecto
      ),
      child: TextFormField(
        focusNode: _focusNode, // Asigna el FocusNode
        keyboardType: TextInputType.visiblePassword,
        obscureText: !_estadoContrasenya,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.all(12.0),
          labelText: "Introduce tu contraseña",
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none, // Elimina el borde interno
          suffixIcon: IconButton(
            icon: Icon(
              _estadoContrasenya ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                _estadoContrasenya = !_estadoContrasenya;
              });
            },
          ),
        ),
      ),
    );
  }
}