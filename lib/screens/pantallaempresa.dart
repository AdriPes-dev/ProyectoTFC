import 'package:fichi/screens/crearempresa.dart';
import 'package:fichi/screens/unirseempresa.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/empresa.dart';

class PantallaEmpresa extends StatefulWidget {
  final Persona personaAutenticada;

  const PantallaEmpresa({
    super.key,
    required this.personaAutenticada,
  });

  @override
  State<PantallaEmpresa> createState() => _PantallaEmpresaState();
}

class _PantallaEmpresaState extends State<PantallaEmpresa> {
  late bool esJefe;

  @override
  void initState() {
    super.initState();
    esJefe = widget.personaAutenticada.empresa != null &&
        widget.personaAutenticada.empresa!.jefe.dni == widget.personaAutenticada.dni;
  }

  @override
  Widget build(BuildContext context) {
    return widget.personaAutenticada.empresa != null
        ? (esJefe ? _buildVistaJefe() : _buildVistaEmpleado())
        : _buildVistaSinEmpresa();
  }

  Widget _buildVistaSinEmpresa() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "No estás asociado a ninguna empresa.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _crearEmpresa,
              child: const Text("Crear nueva empresa"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _unirseAEmpresa,
              child: const Text("Unirse a una empresa existente"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaJefe() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Panel del Jefe", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a estadísticas de empleados
              },
              child: const Text("Ver estadísticas de empleados"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Gestión empleados
              },
              child: const Text("Gestionar empleados"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaEmpleado() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido, ${widget.personaAutenticada.nombre}", 
              style: const TextStyle(fontSize: 20)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ver fichajes propios
              },
              child: const Text("Mis fichajes"),
            ),
          ],
        ),
      ),
    );
  }

  void _crearEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }

  void _unirseAEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnirseAEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }
}