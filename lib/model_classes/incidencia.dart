import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/persona.dart';

class Incidencia {
  final String id;
  final Persona empleado;
  final Empresa empresa;
  final String descripcion;
  final String estado; // "Pendiente", "En proceso", "Resuelta"
  final DateTime fechaReporte;

  Incidencia({
    required this.id,
    required this.empleado,
    required this.empresa,
    required this.descripcion,
    required this.estado,
    required this.fechaReporte,
  });

  // Constructor desde un mapa (JSON)
  Incidencia.map(Map<String, dynamic> obj, Persona empleado, Empresa empresa)
      : id = obj['id'] ?? '',
        empleado = empleado,
        empresa = empresa,
        descripcion = obj['descripcion'] ?? '',
        estado = obj['estado'] ?? 'Pendiente',
        fechaReporte = obj['fechaReporte'] != null
            ? DateTime.parse(obj['fechaReporte'])
            : DateTime.now();
}
