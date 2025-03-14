import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/model_classes/persona.dart';

class Actividad {
  final String id;
  final String titulo;
  final String descripcion;
  final Persona creador;
  final Empresa empresa;
  final DateTime fechaCreacion;

  Actividad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.creador,
    required this.empresa,
    required this.fechaCreacion,
  });

  // Constructor desde un mapa (JSON)
  Actividad.map(Map<String, dynamic> obj, Persona creador, Empresa empresa)
      : id = obj['id'] ?? '',
        titulo = obj['titulo'] ?? '',
        descripcion = obj['descripcion'] ?? '',
        creador = creador,
        empresa = empresa,
        fechaCreacion = obj['fechaCreacion'] != null
            ? DateTime.parse(obj['fechaCreacion'])
            : DateTime.now();
}