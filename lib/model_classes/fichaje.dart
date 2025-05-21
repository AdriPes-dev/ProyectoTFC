import 'dart:convert';

class Fichaje {
  final String id; // UUID
  final String dniEmpleado; // ID del usuario (de Firebase Auth por ejemplo)
  final String cifEmpresa;
  final DateTime entrada;
  final DateTime salida;
  final Duration duracion;
  final bool sincronizado;

  Fichaje({
    required this.id,
    required this.dniEmpleado,
    required this.cifEmpresa,
    required this.entrada,
    required this.salida,
    required this.duracion,
    this.sincronizado = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dniEmpleado': dniEmpleado,
    'cifEmpresa': cifEmpresa,
    'entrada': entrada.toIso8601String(),
    'salida': salida.toIso8601String(),
    'duracion': duracion.inSeconds,
    'sincronizado': sincronizado,
  };

  factory Fichaje.fromJson(Map<String, dynamic> json) => Fichaje(
    id: json['id'],
    dniEmpleado: json['dniEmpleado'],
    cifEmpresa: json['cifEmpresa'],
    entrada: DateTime.parse(json['entrada']),
    salida: DateTime.parse(json['salida']),
    duracion: Duration(seconds: json['duracion']),
    sincronizado: json['sincronizado'] ?? false,
  );

  Map<String, dynamic> toMap() => {
  'id': id,
  'dniEmpleado': dniEmpleado,
  'cifEmpresa': cifEmpresa,
  'entrada': entrada.toIso8601String(),
  'salida': salida.toIso8601String(),
  'duracion': duracion.inSeconds,
  'sincronizado': sincronizado ? 1 : 0,
};

factory Fichaje.fromMap(Map<String, dynamic> map) => Fichaje(
  id: map['id'],
  dniEmpleado: map['dniEmpleado'],
  cifEmpresa: map['cifEmpresa'],
  entrada: DateTime.parse(map['entrada']),
  salida: DateTime.parse(map['salida']),
  duracion: Duration(seconds: map['duracion']),
  sincronizado: map['sincronizado'] == 1,
);

String toJsonString() => json.encode(toJson());
static Fichaje fromJsonString(String jsonString) =>
    Fichaje.fromJson(json.decode(jsonString));

}
