import 'package:fichi/model_classes/empresa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../model_classes/actividad.dart';
import '../services/consultas_firebase.dart';

class PantallaActividadesPendientes extends StatefulWidget {
  final Empresa empresa;

  const PantallaActividadesPendientes({super.key, required this.empresa});

  @override
  State<PantallaActividadesPendientes> createState() => _PantallaActividadesPendientesState();
}

class _PantallaActividadesPendientesState extends State<PantallaActividadesPendientes> {
  late Future<List<Actividad>> _actividades;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _actividades = _cargarActividades();
  }

  Future<List<Actividad>> _cargarActividades() async {
    return await _firebaseService.obtenerActividades(widget.empresa.cif);
  }

  Future<void> _recargarActividades() async {
    setState(() {
      _actividades = _cargarActividades();
    });
  }

  Future<void> _aceptarActividad(Actividad actividad) async {
    try {
      await _firebaseService.actualizarEstadoActividad(actividad.id, true);
      _mostrarMensaje('Actividad aceptada');
      _recargarActividades();
    } catch (e) {
      _mostrarError('Error al aceptar: $e');
    }
  }

  Future<void> _rechazarActividad(Actividad actividad) async {
    try {
      await _firebaseService.actualizarEstadoActividad(actividad.id, false);
      _mostrarMensaje('Actividad rechazada');
      _recargarActividades();
    } catch (e) {
      _mostrarError('Error al rechazar: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Pendientes'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarActividades,
        child: FutureBuilder<List<Actividad>>(
          future: _actividades,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay actividades pendientes'));
            }

            final actividades = snapshot.data!;
            return ListView.builder(
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final actividad = actividades[index];

                return Slidable(
                  key: ValueKey(actividad.id),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _aceptarActividad(actividad),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.check_circle,
                        label: 'Aceptar',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _rechazarActividad(actividad),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.cancel,
                        label: 'Rechazar',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 5,
                    shadowColor: shadowColor,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, size: 40),
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