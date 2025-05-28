import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/incidencia.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';

class RegistrarIncidencia extends StatefulWidget {
  final Persona persona;

  const RegistrarIncidencia({super.key, required this.persona});

  @override
  State<RegistrarIncidencia> createState() => _RegistrarIncidenciaState();
}

class _RegistrarIncidenciaState extends State<RegistrarIncidencia> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  void _registrarIncidencia() async {
  if (_formKey.currentState!.validate()) {
    final nuevaIncidencia = Incidencia(
      id: UniqueKey().toString(),
      dniEmpleado: widget.persona.dni,
      cifEmpresa: widget.persona.empresaCif ?? '',
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      estado: 'Pendiente',
      fechaReporte: DateTime.now(),
    );

    try {
      await firebaseService.guardarIncidenciaEnFirestore(nuevaIncidencia);

      // Feedback al usuario
      CustomSnackbar.mostrar(
  context,
  'Incidencia registrada en Firebase',
  icono: Icons.check_circle,
  texto: Colors.green,
);
      Navigator.pop(context);
    } catch (_) {
      CustomSnackbar.mostrar(
  context,
  'Error al registrar la incidencia',
  icono: Icons.error_outline,
  texto: Colors.red,
);
    }
  }
}

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Incidencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TÍTULO
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la incidencia',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 16),

              // DESCRIPCIÓN
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 24),

              // BOTÓN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Registrar'),
                  onPressed: _registrarIncidencia,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
