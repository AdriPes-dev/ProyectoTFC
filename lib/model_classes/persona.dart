import 'empresa.dart';

class Persona {
  String nombre;
  String apellidos;
  String correo;
  String contrasenya;
  String dni;
  String telefono;
  bool esJefe;
  Empresa? empresa; // <- ahora es opcional

  Persona({
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.contrasenya,
    required this.dni,
    required this.telefono,
    this.esJefe = false,
    this.empresa,
  });

  // Constructor desde mapa (JSON o SQLite)
  Persona.map(Map<String, dynamic> obj)
      : nombre = obj['nombre'] ?? '',
        apellidos = obj['apellidos'] ?? '',
        correo = obj['correo'] ?? '',
        contrasenya = obj['contrasenya'] ?? '',
        dni = obj['dni'] ?? '',
        telefono = obj['telefono'] ?? '',
        esJefe = obj['esJefe'] ?? false,
        empresa = obj['empresa'] != null ? Empresa.map(obj['empresa']) : null;

  // Conversión a mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'contrasenya': contrasenya,
      'dni': dni,
      'telefono': telefono,
      'esJefe': esJefe,
      'empresa': empresa?.toMap(), // si no tiene empresa, será null
    };
  }
}
