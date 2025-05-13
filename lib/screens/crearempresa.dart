import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/services/auth_service.dart';

class CrearEmpresaScreen extends StatefulWidget {
  final Persona persona;

  const CrearEmpresaScreen({super.key, required this.persona});

  @override
  State<CrearEmpresaScreen> createState() => _CrearEmpresaScreenState();
}

class _CrearEmpresaScreenState extends State<CrearEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cifController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Empresa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cifController,
                decoration: InputDecoration(labelText: 'CIF'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el CIF de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Empresa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sectorController,
                decoration: InputDecoration(labelText: 'Sector'),
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nombreEmpresa = _nombreController.text.trim();
                    final cif = _cifController.text.trim();

                    // Validación para evitar duplicados
                    final existePorNombre = await _authService.firestore
                        .collection('empresas')
                        .doc(nombreEmpresa)
                        .get();

                    final existePorCif = await _authService.firestore
                        .collection('empresas')
                        .where('cif', isEqualTo: cif)
                        .limit(1)
                        .get();

                    if (existePorNombre.exists || existePorCif.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ya existe una empresa con ese nombre o CIF.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Crear empresa
                    final nuevaEmpresa = Empresa(
                      cif: _cifController.text.trim(),
                      nombre: nombreEmpresa,
                      direccion: _direccionController.text.trim(),
                      telefono: _telefonoController.text.trim(),
                      email: _emailController.text.trim(),
                      sector: _sectorController.text.trim(),
                      jefeDni: widget.persona.dni
                    );

                    try {
                      await _authService.crearEmpresa(
                        cif: nuevaEmpresa.cif,
                        direccion: nuevaEmpresa.direccion,
                        telefono: nuevaEmpresa.telefono,
                        email: nuevaEmpresa.email,
                        nombreEmpresa: nuevaEmpresa.nombre,
                        sector: nuevaEmpresa.sector,
                        personaActual: widget.persona,
                        jefeDni: widget.persona.dni
                      );

                      // Disposear pantalla y devolver empresa
                      Navigator.pop(context, nuevaEmpresa);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear la empresa: $e')),
                      );
                    }
                  }
                },
                child: Text('Crear Empresa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
