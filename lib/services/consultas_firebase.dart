import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/solicitudentrada.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Empresa?> obtenerEmpresaPorCif(String cif) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection('empresas').doc(cif).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data()!;
        return Empresa.fromMap(data);
      } else {
        print("Empresa con CIF $cif no encontrada.");
        return null;
      }
    } catch (e) {
      print("Error al obtener empresa por CIF: $e");
      return null;
    }
  }
    Future<List<Persona>> obtenerEmpleadosPorEmpresa(String empresaCif) async {
  try {
    final querySnapshot = await _db
        .collection('personas')
        .where('empresaCif', isEqualTo: empresaCif)
        .where('esJefe', isEqualTo: false) // Excluye al jefe
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Persona.fromMap(data);
    }).toList();
  } catch (e) {
    print("Error obteniendo empleados de la empresa $empresaCif: $e");
    return [];
  }
}
  Future<Persona?> obtenerPersonaPorDni(String dni) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('personas')
        .where('dni', isEqualTo: dni)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data = snapshot.docs.first.data();
    return Persona.fromMap(data);
  } catch (e) {
    print("Error al obtener persona por DNI: $e");
    return null;
  }
}

Future<void> guardarIncidenciaEnFirestore(Incidencia incidencia) async {
  try {
   await FirebaseFirestore.instance
    .collection('incidencias')
    .doc(incidencia.id).set({
      'id': incidencia.id,
      'dniEmpleado': incidencia.dniEmpleado,
      'cifEmpresa': incidencia.cifEmpresa,
      'titulo': incidencia.titulo,
      'descripcion': incidencia.descripcion,
      'estado': incidencia.estado,
      'fechaReporte': incidencia.fechaReporte.toIso8601String(),
    });
    print('Incidencia guardada correctamente.');
  } catch (e) {
    print('Error al guardar la incidencia: $e');
    rethrow;
  }
}

Future<List<Incidencia>> obtenerIncidenciasPorEmpresa(String cifEmpresa) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('incidencias')
        .where('cifEmpresa', isEqualTo: cifEmpresa)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Incidencia(
        id: data['id'] ?? doc.id,
        dniEmpleado: data['dniEmpleado'] ?? '',
        cifEmpresa: data['cifEmpresa'] ?? '',
        titulo: data['titulo'] ?? '',
        descripcion: data['descripcion'] ?? '',
        estado: data['estado'] ?? 'Pendiente',
        fechaReporte: data['fechaReporte'] != null
            ? DateTime.parse(data['fechaReporte'])
            : DateTime.now(),
      );
    }).toList();
  } catch (e) {
    print("Error al obtener incidencias de la empresa $cifEmpresa: $e");
    return [];
  }
}

Future<List<Incidencia>> obtenerIncidenciasPendientesPorEmpresa(String cifEmpresa) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('incidencias')
        .where('cifEmpresa', isEqualTo: cifEmpresa)
        .where('estado', isEqualTo: 'Pendiente')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Incidencia(
        id: doc.id,
        dniEmpleado: data['dniEmpleado'],
        cifEmpresa: data['cifEmpresa'],
        titulo: data['titulo'],
        descripcion: data['descripcion'],
        estado: data['estado'],
        fechaReporte: DateTime.parse(data['fechaReporte']),
      );
    }).toList();
  } catch (e) {
    print('Error al obtener incidencias pendientes: $e');
    return [];
  }
}

Future<List<Incidencia>> obtenerIncidenciasLeidasPorEmpresa(String cifEmpresa) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('incidencias')
        .where('cifEmpresa', isEqualTo: cifEmpresa)
        .where('estado', isEqualTo: 'leída')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Incidencia(
        id: doc.id,
        dniEmpleado: data['dniEmpleado'],
        cifEmpresa: data['cifEmpresa'],
        titulo: data['titulo'],
        descripcion: data['descripcion'],
        estado: data['estado'],
        fechaReporte: DateTime.parse(data['fechaReporte']),
      );
    }).toList();
  } catch (e) {
    print('Error al obtener incidencias leídas: $e');
    return [];
  }
}



  Future<void> guardarActividadEnFirestore(Actividad actividad) async {
    try {
      await _db.collection('actividades').add({
        'id': actividad.id,
        'titulo': actividad.titulo,
        'descripcion': actividad.descripcion,
        'dniCreador': actividad.dniCreador,
        'empresaCif': actividad.empresaCif,
        'fechaCreacion': actividad.fechaCreacion.toIso8601String(),
        'fechaActividad': actividad.fechaActividad.toIso8601String(),
        'aceptada': actividad.aceptada,
      });
      print('Actividad guardada correctamente.');
    } catch (e) {
      print('Error al guardar la actividad: $e');
      rethrow;
    }
  }

  Future<void> guardarSolicitudIngreso(SolicitudIngreso solicitud) async {
  try {
    await FirebaseFirestore.instance.collection('solicitudes_ingreso').doc(solicitud.id).set({
      'id': solicitud.id,
      'dniSolicitante': solicitud.dniSolicitante,
      'nombreSolicitante': solicitud.nombreSolicitante,
      'empresaCif': solicitud.empresaCif,
      'nombreEmpresa': solicitud.nombreEmpresa,
      'fechaSolicitud': solicitud.fechaSolicitud.toIso8601String(),
      'aceptada': solicitud.aceptada, // puede ser null al momento de crear
    });

    print('Solicitud de ingreso guardada correctamente.');
  } catch (e) {
    print('Error al guardar la solicitud de ingreso: $e');
    rethrow;
  }
}

Future<List<SolicitudIngreso>> obtenerSolicitudesPorEmpresa(String empresaCif, {bool? aceptada}) async {
  try {
    Query query = FirebaseFirestore.instance
        .collection('solicitudes_ingreso')
        .where('empresaCif', isEqualTo: empresaCif);

    final snapshot = await query.get();

    final solicitudes = snapshot.docs
        .map((doc) => SolicitudIngreso.fromFirestore(doc))
        .toList();

    if (aceptada == null) {
      return solicitudes.where((s) => s.aceptada == null).toList();
    } else {
      return solicitudes.where((s) => s.aceptada == aceptada).toList();
    }
  } catch (e) {
    log("Error al obtener solicitudes de ingreso: $e");
    return [];
  }
}

Future<void> actualizarEstadoSolicitud(String solicitudId, bool aceptada) async {
  try {
    await FirebaseFirestore.instance
        .collection('solicitudes_ingreso')
        .doc(solicitudId)
        .update({
      'aceptada': aceptada,
      'fechaActualizacion': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    throw Exception('Error al actualizar estado de solicitud: $e');
  }
}

Future<void> agregarUsuarioAEmpresa(String dniSolicitante, String empresaCif) async {
    try {
      // 1. Actualizar la persona en la colección 'personas'
      await FirebaseFirestore.instance
          .collection('personas')
          .doc(dniSolicitante)
          .update({
        'empresaCif': empresaCif, // Asignar el CIF de la empresa
      });

      // 2. Actualizar la solicitud en la colección 'solicitudes_ingreso'
      final snapshot = await FirebaseFirestore.instance
          .collection('solicitudes_ingreso')
          .where('dni', isEqualTo: dniSolicitante)
          .where('empresaCif', isEqualTo: empresaCif)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('solicitudes_ingreso')
            .doc(docId)
            .update({'aceptada': true}); // Marcar como aceptada
      }
    } catch (e) {
      print("Error al agregar usuario a la empresa: $e");
      rethrow; // Relanzar el error si es necesario
    }
  }
  Future<void> marcarIncidenciaComoLeida(String incidenciaId) async {
  try {
    await FirebaseFirestore.instance
        .collection('incidencias')
        .doc(incidenciaId)
        .update({'estado': 'leída'});
  } catch (e) {
    throw Exception('Error al marcar la incidencia como leída: $e');
  }
}

Future<List<Actividad>> obtenerActividadesFuturas(String empresaCif) async {
  try {
   final snapshot = await _db
    .collection('actividades')
    .where('empresaCif', isEqualTo: empresaCif)
    .where('aceptada', isEqualTo: true)
    .where('fechaActividad', isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
    .orderBy('fechaActividad') // ascendente
    .get();

    log("Actividades futuras encontradas: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList();
  } catch (e) {
    log('Error en obtenerActividadesFuturas: $e');
    rethrow;
  }
}

Future<List<Actividad>> obtenerActividades(String empresaCif) async {
  try {
    final snapshot = await _db
        .collection('actividades')
        .where('empresaCif', isEqualTo: empresaCif)
        .where('aceptada', isEqualTo: true)
        .orderBy('fechaActividad', descending: true)
        .get();

    log("Actividades encontradas: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList();
  } catch (e) {
    log('Error en obtenerActividadesRecientes: $e');
    rethrow;
  }
}



   Future<List<Actividad>> obtenerActividadesPendientes(String empresaCif) async {
    final snapshot = await _db
        .collection('actividades')
        .where('empresaCif', isEqualTo: empresaCif)
        .where('aceptada', isEqualTo: false)
        .orderBy('fechaActividad', descending: true)
        .get();

    return snapshot.docs.map((doc) => Actividad.fromFirestore(doc)).toList();
  }

  Future<void> actualizarPersona(Persona persona) async {
  try {
    await FirebaseFirestore.instance
        .collection('personas')
        .doc(persona.dni)
        .update(persona.toMap());
    print("Persona actualizada correctamente.");
  } catch (e) {
    print("Error al actualizar persona: $e");
    rethrow;
  }
}
}

