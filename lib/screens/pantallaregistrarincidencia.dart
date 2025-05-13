import 'package:flutter/material.dart';

class RegistrarIncidencia extends StatelessWidget {
  const RegistrarIncidencia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Incidencia'),
      ),
      body: const Center(
        child: Text('Pantalla para registrar una incidencia'),
      ),
    );
  }
}
