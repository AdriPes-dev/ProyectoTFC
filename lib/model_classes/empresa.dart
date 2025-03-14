class Empresa {
  String cif;
  String nombre;
  String direccion;
  String telefono;
  String email;
  String sector;

  Empresa({
    required this.cif,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.sector,
  });

   // Constructor desde un mapa (JSON)
  Empresa.map(Map<String, dynamic> obj)
      : cif = obj['cif'] ?? '',
        nombre = obj['nombre'] ?? '',
        direccion = obj['direccion'] ?? '',
        telefono = obj['telefono'] ?? '',
        email = obj['email'] ?? '',
        sector = obj['sector'] ?? '';
}