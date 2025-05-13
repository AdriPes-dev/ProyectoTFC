class Incidencia {
  String id;
  String dniEmpleado;
  String cifEmpresa;
  String titulo;
  String descripcion;
  String estado; // "Pendiente", "Resuelta"
  DateTime fechaReporte;


  Incidencia({
    required this.id,
    required this.dniEmpleado,
    required this.cifEmpresa,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.fechaReporte,
  });

  // Constructor desde un mapa (JSON o Firestore)
   Incidencia.fromMap(Map<String, dynamic> obj)
      : id = obj['id'] ?? '',
        dniEmpleado = obj['dniEmpleado'] ?? '',
        cifEmpresa = obj['cifEmpresa'] ?? '',
        titulo = obj['titulo'] ?? '',
        descripcion = obj['descripcion'] ?? '',
        estado = obj['estado'] ?? 'Pendiente',
        fechaReporte = obj['fechaReporte'] != null
            ? DateTime.parse(obj['fechaReporte'])
            : DateTime.now();

  // Conversión a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dniEmpleado': dniEmpleado,
      'cifEmpresa': cifEmpresa,
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
      'fechaReporte': fechaReporte.toIso8601String(),
    };
  }
}
