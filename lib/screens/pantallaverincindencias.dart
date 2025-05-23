import 'dart:developer';

import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PantallaIncidenciasEmpresa extends StatefulWidget {
  final Empresa empresa;

  const PantallaIncidenciasEmpresa({super.key, required this.empresa});

  @override
  State<PantallaIncidenciasEmpresa> createState() => _PantallaIncidenciasEmpresaState();
}

class _PantallaIncidenciasEmpresaState extends State<PantallaIncidenciasEmpresa> {
  late Future<List<Map<String, dynamic>>> _incidenciasConEmpleado;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _incidenciasConEmpleado = cargarIncidenciasConEmpleados();
  }

  Future<List<Map<String, dynamic>>> cargarIncidenciasConEmpleados() async {
    final service = FirebaseService();
    final incidencias = await service.obtenerIncidenciasPendientesPorEmpresa(widget.empresa.cif);

    List<Map<String, dynamic>> resultado = [];
    for (var incidencia in incidencias) {
      final empleado = await service.obtenerPersonaPorDni(incidencia.dniEmpleado);
      if (empleado != null) {
        resultado.add({
          'incidencia': incidencia,
          'empleado': empleado,
        });
      }
    }
    return resultado;
  }

  Future<void> recargarIncidencias() async {
    setState(() {
      _incidenciasConEmpleado = cargarIncidenciasConEmpleados();
    });
  }

    @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias de la Empresa'),
      ),
      body: RefreshIndicator(
        onRefresh: recargarIncidencias,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _incidenciasConEmpleado,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay incidencias registradas.'));
            }

            final lista = snapshot.data!;
            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final incidencia = lista[index]['incidencia'] as Incidencia;
                final empleado = lista[index]['empleado'] as Persona;

                return Slidable(
                  key: ValueKey(incidencia.id),
                  startActionPane: ActionPane(
                    extentRatio: 0.25,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _marcarComoLeida(incidencia),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.check_circle,
                        label: 'Leída',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 5,
                    shadowColor: shadowColor,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(empleado.nombre[0].toUpperCase()),
                      ),
                      title: Text(incidencia.titulo),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Empleado: ${empleado.nombreCompleto}'),
                          Text('Descripción: ${incidencia.descripcion}'),
                          Text('Estado: ${incidencia.estado}'),
                          Text('Fecha: ${incidencia.fechaReporte.toLocal().toString().substring(0, 16)}'),
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
  Future<void> _marcarComoLeida(Incidencia incidencia) async {
    
  try {
    log(incidencia.id);
    await _firebaseService.marcarIncidenciaComoLeida(incidencia.id);
    _mostrarMensaje('Incidencia marcada como leída');
  } catch (e) {
    _mostrarError('No se pudo marcar como leída: $e');
  }
}

void _mostrarMensaje(String mensaje) {
  CustomSnackbar.mostrar(
  context,
  mensaje,
  icono: Icons.check_circle,
  texto: Colors.green,
);
}

void _mostrarError(String mensaje) {

  CustomSnackbar.mostrar(
  context,
  mensaje,
  icono: Icons.error_outline,
  texto: Colors.red,
);
}
}
