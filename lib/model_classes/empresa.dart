class Empresa {
  final String cif;
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String sector;
  final String? jefeDni;
  
  // No almacenamos empleados aquí para evitar duplicidad de datos
  // Los empleados se obtendrán por consulta separada

  Empresa({
    required this.cif,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.sector,
    this.jefeDni,
  });

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      cif: map['cif'] ?? '',
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      sector: map['sector'] ?? '',
      jefeDni: map['jefeDni'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cif': cif,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sector': sector,
      'jefeDni': jefeDni,
    };
  }
}