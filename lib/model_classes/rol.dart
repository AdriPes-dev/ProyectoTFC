import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/persona.dart';

class Rol {
  final String id;
  final String nombre;
  final String descripcion;
  final Empresa empresa;
  final List<Persona> empleados; // Personas con este rol

  Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.empresa,
    required this.empleados,
  });

  // Constructor desde un mapa (JSON)
  Rol.map(Map<String, dynamic> obj, Empresa empresa, List<Persona> empleados)
      : id = obj['id'] ?? '',
        nombre = obj['nombre'] ?? '',
        descripcion = obj['descripcion'] ?? '',
        empresa = empresa,
        empleados = empleados;
}