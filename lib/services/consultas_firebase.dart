import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';

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
    await FirebaseFirestore.instance.collection('incidencias').add({
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


}
