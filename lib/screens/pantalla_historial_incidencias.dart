import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 400 + index * 50),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: _AnimatedCardWrapper(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.25),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(incidencia.fechaReporte),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedCardWrapper({required this.child});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.97);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}