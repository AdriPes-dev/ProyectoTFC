import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';

class PantallaHistorialIncidenciasEmpresa extends StatefulWidget {
  final Empresa empresa;

  const PantallaHistorialIncidenciasEmpresa({super.key, required this.empresa});

  @override
  State<PantallaHistorialIncidenciasEmpresa> createState() => _PantallaHistorialIncidenciasEmpresaState();
}

class _PantallaHistorialIncidenciasEmpresaState extends State<PantallaHistorialIncidenciasEmpresa> {
  late Future<List<Map<String, dynamic>>> _incidenciasConEmpleado;

  @override
  void initState() {
    super.initState();
    _incidenciasConEmpleado = cargarIncidenciasConEmpleados();
  }

  Future<List<Map<String, dynamic>>> cargarIncidenciasConEmpleados() async {
    final service = FirebaseService();
    final incidencias = await service.obtenerIncidenciasLeidasPorEmpresa(widget.empresa.cif);

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

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Incidencias')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _incidenciasConEmpleado,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay incidencias registradas. Todavía.'));
          }

          final lista = snapshot.data!;
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final incidencia = lista[index]['incidencia'] as Incidencia;
              final empleado = lista[index]['empleado'] as Persona;

             return Card(
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
);

            },
          );
        },
      ),
    );
  }
}