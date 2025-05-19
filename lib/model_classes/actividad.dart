import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Actividad.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Actividad(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      dniCreador: data['dniCreador'] ?? '',
      empresaCif: data['empresaCif'] ?? '',
      fechaCreacion: (data['fechaCreacion'] is Timestamp)
    ? (data['fechaCreacion'] as Timestamp).toDate()
    : DateTime.tryParse(data['fechaCreacion'] ?? '') ?? DateTime.now(),
      fechaActividad: (data['fechaActividad'] is Timestamp)
    ? (data['fechaActividad'] as Timestamp).toDate()
    : DateTime.tryParse(data['fechaActividad'] ?? '') ?? DateTime.now(),
      aceptada: data['aceptada'],
    );
  }
}
