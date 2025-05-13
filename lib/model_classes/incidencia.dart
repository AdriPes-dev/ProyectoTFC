import 'empresa.dart';
import 'persona.dart';

class Incidencia {
  String id;
  Persona empleado;
  Empresa empresa;
  String descripcion;
  String estado; // "Pendiente", "En proceso", "Resuelta"
  DateTime fechaReporte;
  bool? aceptada;

  Incidencia({
    required this.id,
    required this.empleado,
    required this.empresa,
    required this.descripcion,
    required this.estado,
    required this.fechaReporte,
  });

  // Constructor desde un mapa (JSON o Firestore)
  Incidencia.map(Map<String, dynamic> obj, Persona empleado, Empresa empresa)
      : id = obj['id'] ?? '',
        empleado = empleado,
        empresa = empresa,
        descripcion = obj['descripcion'] ?? '',
        estado = obj['estado'] ?? 'Pendiente',
        fechaReporte = obj['fechaReporte'] != null
            ? DateTime.parse(obj['fechaReporte'])
            : DateTime.now();

  // Conversión a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empleado': empleado.toMap(),
      'empresa': empresa.toMap(),
      'descripcion': descripcion,
      'estado': estado,
      'fechaReporte': fechaReporte.toIso8601String(),
    };
  }
}
