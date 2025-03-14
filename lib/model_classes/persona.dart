import 'package:fichi/model_classes/empresa.dart';

class Persona{
  Persona(this._nif, this._nombre, this._empresa, this._inicioFicha);
  
  final String _nif;
  final String _nombre;
  final Empresa _empresa;
  final DateTime _inicioFicha;

   // Constructor desde un mapa (JSON)
  Persona.map(Map<String, dynamic> obj)
      : _nif = obj['nif'] ?? '',
        _nombre = obj['nombre'] ?? '',
        _empresa = Empresa.map(obj['empresa'] ?? {}), // Convertir JSON a Empresa
        _inicioFicha = obj['inicioFicha'] != null
            ? DateTime.parse(obj['inicioFicha']) // Convertir String a DateTime
            : DateTime.now(); // Fecha por defecto

  String get nif => _nif;
  String get nombre => _nombre;
  Empresa get empresa => _empresa;
  DateTime get inicioFicha => _inicioFicha;
}