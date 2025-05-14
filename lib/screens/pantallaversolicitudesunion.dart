import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:fichi/model_classes/solicitudentrada.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SolicitudesEntradaScreen extends StatefulWidget {
  final String empresaCif;

  const SolicitudesEntradaScreen({
    super.key,
    required this.empresaCif,
  });

  @override
  State<SolicitudesEntradaScreen> createState() =>
      _SolicitudesEntradaScreenState();
}

class _SolicitudesEntradaScreenState extends State<SolicitudesEntradaScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<SolicitudIngreso> _solicitudes = [];
  bool _cargando = true;
  String _filtro = 'Pendientes'; // 'Pendientes', 'Aceptadas', 'Rechazadas', 'Todas'

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _cargando = true);

    try {
      bool? estadoFiltro;
      if (_filtro == 'Pendientes') {
        estadoFiltro = null;
      } else if (_filtro == 'Aceptadas') {
        estadoFiltro = true;
      } else if (_filtro == 'Rechazadas') {
        estadoFiltro = false;
      }

      final solicitudes = await _firebaseService.obtenerSolicitudesPorEmpresa(
        widget.empresaCif,
        aceptada: estadoFiltro,
      );

      setState(() {
        _solicitudes = solicitudes;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error al cargar solicitudes: $e');
    }
  }

  Future<String> _obtenerNombreSolicitante(String dni) async {
  try {
    
    final persona = await _firebaseService.obtenerPersonaPorDni(dni);
    
    if (persona != null) {
      return persona.nombre;
    } else {
      return 'Nombre no disponible';
    }
  } catch (e) {
    return 'Error al obtener nombre';
  }
} 


  Future<void> _actualizarEstadoSolicitud(SolicitudIngreso solicitud, bool aceptada) async {
    try {
      await _firebaseService.actualizarEstadoSolicitud(solicitud.id, aceptada);

      // Si se acepta, añadir al usuario a la empresa
      if (aceptada) {
        await _firebaseService.agregarUsuarioAEmpresa(
          solicitud.dniSolicitante,
          widget.empresaCif,
        );
      }

      _mostrarMensaje('Solicitud ${aceptada ? 'aceptada' : 'rechazada'}');
      _cargarSolicitudes(); // Recargar la lista
    } catch (e) {
      _mostrarError('Error al actualizar solicitud: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _mostrarError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarDialogoConfirmacion(SolicitudIngreso solicitud, bool aceptar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aceptar ? 'Aceptar solicitud' : 'Rechazar solicitud'),
        content: Text(
          aceptar
              ? '¿Aceptar a ${solicitud.dniSolicitante} en tu empresa?'
              : '¿Rechazar la solicitud de ${solicitud.dniSolicitante}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _actualizarEstadoSolicitud(solicitud, aceptar);
            },
            child: Text(
              aceptar ? 'Aceptar' : 'En proceso',
              style: TextStyle(
                color: aceptar ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaSolicitud(SolicitudIngreso solicitud) {
  return Slidable(
    key: ValueKey(solicitud.id),
    closeOnScroll: true,
    startActionPane: ActionPane(
      motion: const DrawerMotion(),
      children: [
        SlidableAction(
          onPressed: (_) => _mostrarDialogoConfirmacion(solicitud, true),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.check,
          label: 'Aceptar',
        ),
      ],
    ),
    endActionPane: ActionPane(
      motion: const DrawerMotion(),
      children: [
        SlidableAction(
          onPressed: (_) => _mostrarDialogoConfirmacion(solicitud, false),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.close,
          label: 'Rechazar',
        ),
      ],
    ),
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    solicitud.dniSolicitante,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: solicitud.aceptada == null
                        ? Colors.orange.withOpacity(0.2)
                        : solicitud.aceptada!
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    solicitud.aceptada == null
                        ? 'Pendiente'
                        : solicitud.aceptada!
                            ? 'Aceptada'
                            : 'En proceso',
                    style: TextStyle(
                      color: solicitud.aceptada == null
                          ? Colors.orange
                          : solicitud.aceptada!
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetalleSolicitud('DNI', solicitud.dniSolicitante),
            _buildDetalleSolicitud('Cif de la empresa', solicitud.empresaCif),
            _buildDetalleSolicitud(
              'Fecha',
              '${solicitud.fechaSolicitud.day}/${solicitud.fechaSolicitud.month}/${solicitud.fechaSolicitud.year}',
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDetalleSolicitud(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de unión'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() => _filtro = value);
              _cargarSolicitudes();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Todas',
                child: Text('Todas las solicitudes'),
              ),
              const PopupMenuItem(
                value: 'Pendientes',
                child: Text('Solicitudes pendientes'),
              ),
              const PopupMenuItem(
                value: 'Aceptadas',
                child: Text('Solicitudes aceptadas'),
              ),
              const PopupMenuItem(
                value: 'Rechazadas',
                child: Text('Solicitudes rechazadas'),
              ),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _solicitudes.isEmpty
              ? Center(
                  child: Text(
                    'No hay solicitudes ${_filtro.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarSolicitudes,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom:8),
itemCount: _solicitudes.length,
itemBuilder: (context, index) {
return _buildTarjetaSolicitud(_solicitudes[index]);
},
),
),
);
}
}