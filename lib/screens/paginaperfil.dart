import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';

class PantallaPerfil extends StatefulWidget {
  final Persona persona;

  const PantallaPerfil({super.key, required this.persona});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Encabezado con la foto y nombre
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: AppColors.primaryBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    CircleAvatar(
      backgroundColor: AppColors.gradientPurple,
      radius: 50,
      child: Text(
        widget.persona.nombre[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 40,
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Text(
        '${widget.persona.nombre} ${widget.persona.apellidos}',
        overflow: TextOverflow.ellipsis, // Corta con "..."
        softWrap: false,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.black,
        ),
      ),
    ),
  ],
),
              ),
            ),
          ),

          // Información de la persona
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              "Perfil de ${widget.persona.nombre}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTextFieldN("Correo", widget.persona.correo),
          _buildTextFieldN("DNI", widget.persona.dni),
          _buildTextField("Nombre", widget.persona.nombre),
          _buildTextField("Apellidos", widget.persona.apellidos),
          _buildTextField("Teléfono", widget.persona.telefono),
        ],
      ),
    );
  }

  Widget _buildTextFieldN(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        enabled: false, // Hace que el campo sea solo lectura
        controller: TextEditingController(text: value), // Muestra el valor de la persona
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  // Método para crear campos de texto
  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        enabled: true, // Hace que el campo sea solo lectura
        controller: TextEditingController(text: value), // Muestra el valor de la persona
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}