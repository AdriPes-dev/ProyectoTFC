import 'package:flutter/material.dart';

class PantallaRegistrarActividad extends StatelessWidget {
  const PantallaRegistrarActividad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Actividad'),
      ),
      body: const Center(
        child: Text('Pantalla para registrar una actividad'),
      ),
    );
  }
}
