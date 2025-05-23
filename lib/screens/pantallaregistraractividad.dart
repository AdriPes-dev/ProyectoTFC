import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Asegúrate de importar la clase Persona

class CrearActividadScreen extends StatefulWidget {
  final Persona persona; // Recibimos la persona por parámetro

  CrearActividadScreen({Key? key, required this.persona}) : super(key: key);

  @override
  _CrearActividadScreenState createState() => _CrearActividadScreenState();
}

class _CrearActividadScreenState extends State<CrearActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaActividad;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _fechaActividad) {
      setState(() {
        _fechaActividad = picked;
      });
    }
  }

  void _guardarActividad() async {
  if (_formKey.currentState!.validate() && _fechaActividad != null) {
    // Verificamos si el 'empresaCif' es nulo o vacío
    String? empresaCif = widget.persona.empresaCif;
    if (empresaCif == null || empresaCif.isEmpty) {
      // Si el 'empresaCif' es nulo o vacío, asignamos un valor por defecto o mostramos un error
      // Aquí lo dejamos vacío o le puedes asignar algún valor por defecto
      empresaCif = "sin_cif"; // Cambia esto según tu necesidad
      // O si prefieres lanzar un error si la empresaCif es obligatorio
      // throw Exception('Empresa CIF no proporcionado');
    }

    final actividad = Actividad(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      dniCreador: widget.persona.dni,
      empresaCif: empresaCif,  // Asignamos el valor verificado
      fechaCreacion: DateTime.now(),
      fechaActividad: _fechaActividad!,
      aceptada: false, // Se puede modificar según el flujo de tu app
    );

    try {
      await _firebaseService.guardarActividadEnFirestore(actividad);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Actividad guardada correctamente.')),
      );
      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la actividad.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título de la actividad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el título de la actividad';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción de la actividad',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // El campo de DNI ya no es necesario porque lo obtenemos de la persona
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _fechaActividad == null
                          ? 'Seleccionar fecha de actividad'
                          : 'Fecha de actividad: ${DateFormat('yyyy-MM-dd').format(_fechaActividad!)}',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_fechaActividad == null) {
                        return 'Por favor seleccione la fecha de la actividad';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Crear Actividad'),
                  onPressed: _guardarActividad,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
