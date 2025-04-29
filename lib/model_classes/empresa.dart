import 'package:fichi/model_classes/persona.dart';

class Empresa {
  String cif;
  String nombre;
  String direccion;
  String telefono;
  String email;
  String sector;
  Persona jefe;
  List<Persona> empleados;

  Empresa({
    required this.cif,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.sector,
    required this.jefe,
    this.empleados = const [],
  });

  // Constructor desde mapa
  Empresa.map(Map<String, dynamic> obj)
      : cif = obj['cif'] ?? '',
        nombre = obj['nombre'] ?? '',
        direccion = obj['direccion'] ?? '',
        telefono = obj['telefono'] ?? '',
        email = obj['email'] ?? '',
        sector = obj['sector'] ?? '',
        jefe = Persona.map(obj['jefe'] ?? {}),
        empleados = (obj['empleados'] as List<dynamic>?)
                ?.map((e) => Persona.map(e))
                .toList() ??
            []; // Lista vacía por defecto

  // Conversión a mapa
  Map<String, dynamic> toMap() {
    return {
      'cif': cif,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sector': sector,
      'jefe': jefe.toMap(),
      'empleados': empleados.map((e) => e.toMap()).toList(),
    };
  }
}