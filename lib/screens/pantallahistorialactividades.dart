import 'package:fichi/model_classes/empresa.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model_classes/actividad.dart';
import '../services/consultas_firebase.dart';

class PantallaHistorialActividades extends StatefulWidget {
  final Empresa empresa;

  const PantallaHistorialActividades({super.key, required this.empresa});

  @override
  State<PantallaHistorialActividades> createState() => _PantallaHistorialActividadesState();
}

class _PantallaHistorialActividadesState extends State<PantallaHistorialActividades> {
  late Future<List<Actividad>> _historialActividades;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _historialActividades = _cargarHistorial();
  }

  Future<List<Actividad>> _cargarHistorial() async {
    return await _firebaseService.obtenerHistorialActividades(widget.empresa.cif);
  }

  Future<void> _recargarHistorial() async {
    setState(() {
      _historialActividades = _cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Actividades'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarHistorial,
        child: FutureBuilder<List<Actividad>>(
          future: _historialActividades,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay actividades en el historial'));
            }

            final actividades = snapshot.data!;
            return ListView.builder(
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final actividad = actividades[index];

                return Card(
                  elevation: 5,
                  shadowColor: shadowColor,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.history, size: 40),
                    title: Text(actividad.titulo),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(actividad.descripcion),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(actividad.fechaActividad),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
