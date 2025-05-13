class Persona {
  final String dni;
  final String nombre;
  final String apellidos;
  final String correo;
  final String telefono;
  final bool esJefe;
  String? empresaCif;

  Persona({
    required this.dni,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    this.esJefe = false,
    this.empresaCif,
  });

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      dni: map['dni'] ?? '',
      nombre: map['nombre'] ?? '',
      apellidos: map['apellidos'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      esJefe: map['esJefe'] ?? false,
      empresaCif: map['empresaCif'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'esJefe': esJefe,
      'empresaCif': empresaCif,
    };
  }

  String get nombreCompleto => '$nombre $apellidos';
}