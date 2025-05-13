import 'empresa.dart';
import 'persona.dart';

class Rol {
  String id;
  String nombre;
  String descripcion;
  Empresa empresa;
  List<Persona> empleados;

  Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.empresa,
    this.empleados = const [],
  });

  // Constructor desde un mapa (JSON o Firestore)
  Rol.map(Map<String, dynamic> obj, Empresa empresa, List<Persona> empleados)
      : id = obj['id'] ?? '',
        nombre = obj['nombre'] ?? '',
        descripcion = obj['descripcion'] ?? '',
        empresa = empresa,
        empleados = empleados;

  // Conversión a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'empresa': empresa.toMap(),
      'empleados': empleados.map((e) => e.toMap()).toList(),
    };
  }
}