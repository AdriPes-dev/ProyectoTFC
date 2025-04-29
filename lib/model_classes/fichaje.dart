class Fichaje {
  final int? id;
  final String nif;
  final String empresaNombre;
  final DateTime horaEntrada;
  final DateTime? horaSalida; // Puede ser nulo hasta que fiche salida.

  Fichaje({
    this.id,
    required this.nif,
    required this.empresaNombre,
    required this.horaEntrada,
    this.horaSalida,
  });

  // Para guardar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nif': nif,
      'empresaNombre': empresaNombre,
      'horaEntrada': horaEntrada.toIso8601String(),
      'horaSalida': horaSalida?.toIso8601String(),
    };
  }

  // Para leer de la base de datos
  factory Fichaje.fromMap(Map<String, dynamic> map) {
    return Fichaje(
      id: map['id'],
      nif: map['nif'],
      empresaNombre: map['empresaNombre'],
      horaEntrada: DateTime.parse(map['horaEntrada']),
      horaSalida: map['horaSalida'] != null ? DateTime.parse(map['horaSalida']) : null,
    );
  }
}
