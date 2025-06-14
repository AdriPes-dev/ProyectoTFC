
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/theme/appcolors.dart';
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
    CustomSnackbar.mostrar(
  context,
  mensaje,
  icono: Icons.check_circle,
  texto: Colors.green,
);
  }

  void _mostrarError(String error) {
    CustomSnackbar.mostrar(
  context,
  error,
  icono: Icons.error_outline,
  texto: Colors.red,
);
  }

  Future<String> _obtenerNombrePorDni(String dni) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('personas')
        .where('dni', isEqualTo: dni)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final nombre = data['nombre'] ?? '';
      final apellido = data['apellidos'] ?? '';
      return '$nombre $apellido'.trim().isEmpty ? 'Nombre no disponible' : '$nombre $apellido';
    } else {
      return 'Nombre no disponible';
    }
  } catch (e) {
    print('Error al obtener nombre por DNI: $e');
    return 'Nombre no disponible';
  }
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
              aceptar ? 'Aceptar' : 'Rechazada',
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
      elevation: 5,
      shadowColor: AppColors.primaryBlue.withOpacity(0.5),
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
  child: FutureBuilder<String>(
    future: _obtenerNombrePorDni(solicitud.dniSolicitante),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text(
          'Cargando...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      } else if (snapshot.hasError) {
        return const Text(
          'Error al cargar nombre',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          snapshot.data ?? 'Nombre no disponible',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        );
      }
    },
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
                            : 'Rechazada',
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

  Widget _buildTarjetaSolicitudNoSlide(SolicitudIngreso solicitud) {
  return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shadowColor: AppColors.primaryBlue.withOpacity(0.5),
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
  child: FutureBuilder<String>(
    future: _obtenerNombrePorDni(solicitud.dniSolicitante),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text(
          'Cargando...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      } else if (snapshot.hasError) {
        return const Text(
          'Error al cargar nombre',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          snapshot.data ?? 'Nombre no disponible',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        );
      }
    },
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
                            : 'Rechazada',
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
    setState(() {
      _filtro = value;
      _cargarSolicitudes();
    });
  },
  itemBuilder: (BuildContext context) => [
    const PopupMenuItem(value: 'Pendientes', child: Text('Pendientes')),
    const PopupMenuItem(value: 'Aceptadas', child: Text('Aceptadas')),
    const PopupMenuItem(value: 'Rechazadas', child: Text('Rechazadas')),
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
  final solicitud = _solicitudes[index];

  // Si el filtro actual es "Pendientes", usa tarjeta deslizable
  if (_filtro == 'Pendientes') {
    return _buildTarjetaSolicitud(solicitud);
  } else {
    return _buildTarjetaSolicitudNoSlide(solicitud);
  }
},
),
),
);
}
}