import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitudIngreso {
  final String id;
  final String dniSolicitante;
  final String nombreSolicitante;
  final String empresaCif;
  final String nombreEmpresa;
  final DateTime fechaSolicitud;
  bool? aceptada; // null = pendiente, true = aceptada, false = rechazada

  SolicitudIngreso({
    required this.id,
    required this.dniSolicitante,
    required this.nombreSolicitante,
    required this.empresaCif,
    required this.nombreEmpresa,
    required this.fechaSolicitud,
    this.aceptada, // Puede ser null al momento de crear la solicitud
  });

  factory SolicitudIngreso.fromMap(Map<String, dynamic> map) {
    return SolicitudIngreso(
      id: map['id'] ?? '',
      dniSolicitante: map['dni'] ?? '',
      nombreSolicitante: map['nombreSolicitante'] ?? '',
      empresaCif: map['empresaCif'] ?? '',
      nombreEmpresa: map['nombreEmpresa'] ?? '',
      fechaSolicitud: map['fechaSolicitud'] != null
          ? DateTime.parse(map['fechaSolicitud'])
          : DateTime.now(),
      aceptada: map['aceptada'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dniSolicitante': dniSolicitante,
      'nombreSolicitante': nombreSolicitante,
      'empresaCif': empresaCif,
      'nombreEmpresa': nombreEmpresa,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'aceptada': aceptada,
    };
  }

  factory SolicitudIngreso.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return SolicitudIngreso(
    id: doc.id,
    dniSolicitante: data['dniSolicitante'] ?? data['dni'] ?? '',
    nombreSolicitante: data['nombreSolicitante'] ?? '',
    empresaCif: data['empresaCif'] ?? '',
    nombreEmpresa: data['nombreEmpresa'] ?? '',
    fechaSolicitud: data['fechaSolicitud'] != null
        ? (data['fechaSolicitud'] as Timestamp).toDate()
        : DateTime.now(),
    aceptada: data['aceptada'],
  );
}

}
