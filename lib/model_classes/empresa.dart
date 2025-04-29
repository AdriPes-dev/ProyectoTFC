import 'package:fichi/model_classes/persona.dart';

class Empresa {
  String cif;
  String nombre;
  String direccion;
  String telefono;
  String email;
  String sector;
  Persona jefe;

  Empresa({
    required this.cif,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.sector,
    required this.jefe,
  });

  // Constructor desde un mapa (por ejemplo, desde Firebase o SQLite)
  Empresa.map(Map<String, dynamic> obj)
      : cif = obj['cif'] ?? '',
        nombre = obj['nombre'] ?? '',
        direccion = obj['direccion'] ?? '',
        telefono = obj['telefono'] ?? '',
        email = obj['email'] ?? '',
        sector = obj['sector'] ?? '',
        jefe = Persona.map(obj['jefe'] ?? {});

  // Conversión a mapa para guardar en base de datos
  Map<String, dynamic> toMap() {
    return {
      'cif': cif,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sector': sector,
      'jefe': jefe.toMap(),
    };
  }
}
