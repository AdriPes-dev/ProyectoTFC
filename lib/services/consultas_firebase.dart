import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/empresa.dart';
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

}
