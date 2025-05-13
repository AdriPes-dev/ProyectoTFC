class Actividad {
  final String id;
  final String titulo;
  final String descripcion;
  final String dniCreador;
  final String empresaCif;
  final DateTime fechaCreacion;
  final DateTime fechaActividad;
  bool? aceptada;

  Actividad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.dniCreador,
    required this.empresaCif,
    required this.fechaActividad,
    required this.fechaCreacion,
    this.aceptada,
  });

  // Constructor desde un mapa (JSON)
  Actividad.fromMap(Map<String, dynamic> obj)
      : id = obj['id'] ?? '',
        titulo = obj['titulo'] ?? '',
        descripcion = obj['descripcion'] ?? '',
        dniCreador = obj['dniCreador'] ?? '',
        empresaCif = obj['empresaCif'] ?? '',
        fechaCreacion = obj['fechaCreacion'] != null
            ? DateTime.parse(obj['fechaCreacion'])
            : DateTime.now(),
        fechaActividad = obj['fechaActividad'] != null
            ? DateTime.parse(obj['fechaActividad'])
            : DateTime.now(),
        aceptada = obj['aceptada'];

  // Conversión a mapa (por ejemplo para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'dniCreador': dniCreador,
      'empresaCif': empresaCif,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActividad': fechaActividad.toIso8601String(),
      'aceptada': aceptada,
    };
  }
}
