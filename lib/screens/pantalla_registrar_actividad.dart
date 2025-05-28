import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CrearActividadScreen extends StatefulWidget {
  final Persona persona;

  CrearActividadScreen({Key? key, required this.persona}) : super(key: key);

  @override
  _CrearActividadScreenState createState() => _CrearActividadScreenState();
}

class _CrearActividadScreenState extends State<CrearActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaActividad;
  TimeOfDay? _horaActividad;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _fechaActividad = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _horaActividad = picked;
      });
    }
  }

  Future<bool> _mostrarDialogoHoraPorDefecto() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hora no seleccionada'),
        content: const Text('No has seleccionado una hora para la actividad.\n\n'
            'Se usará automáticamente las 00:00 como hora por defecto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _guardarActividad() async {
    if (!_formKey.currentState!.validate() || _fechaActividad == null) return;

    // Validar fecha en el pasado
    final hoy = DateTime.now();
    final fechaSeleccionada = DateTime(
      _fechaActividad!.year,
      _fechaActividad!.month,
      _fechaActividad!.day,
    );
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    if (fechaSeleccionada.isBefore(hoySinHora)) {
      CustomSnackbar.mostrar(
        context,
        'No puedes registrar una actividad en una fecha pasada.',
        icono: Icons.warning_amber,
        texto: Colors.orange,
      );
      return;
    }

    // Manejar hora no seleccionada
    if (_horaActividad == null) {
      final aceptarHoraPorDefecto = await _mostrarDialogoHoraPorDefecto();
      if (!aceptarHoraPorDefecto) return;
      
      _horaActividad = const TimeOfDay(hour: 0, minute: 0);
    }

    // Combinar fecha y hora
    final fechaFinal = DateTime(
      _fechaActividad!.year,
      _fechaActividad!.month,
      _fechaActividad!.day,
      _horaActividad!.hour,
      _horaActividad!.minute,
    );

    String? empresaCif = widget.persona.empresaCif ?? "sin_cif";

    final actividad = Actividad(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      dniCreador: widget.persona.dni,
      empresaCif: empresaCif,
      fechaCreacion: DateTime.now(),
      fechaActividad: fechaFinal,
      aceptada: false,
    );

    try {
      await _firebaseService.guardarActividadEnFirestore(actividad);
      CustomSnackbar.mostrar(
        context,
        'Actividad guardada correctamente.',
        icono: Icons.check_circle,
        texto: Colors.green,
      );
      Navigator.pop(context);
    } catch (e) {
      CustomSnackbar.mostrar(
        context,
        'Error al guardar la actividad: ${e.toString()}',
        icono: Icons.error_outline,
        texto: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Actividad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la actividad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingrese el título de la actividad' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la actividad',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingrese la descripción' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _fechaActividad == null
                          ? 'Seleccionar fecha de actividad'
                          : 'Fecha: ${DateFormat('yyyy-MM-dd').format(_fechaActividad!)}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _fechaActividad == null ? 'Por favor seleccione la fecha' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _horaActividad == null
                          ? 'Seleccionar hora de actividad (opcional)'
                          : 'Hora: ${_horaActividad!.format(context)}',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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