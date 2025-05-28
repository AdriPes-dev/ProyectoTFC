import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/components/custom_snackbar.dart';
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
                  final pattern = RegExp(r'^[A-HJNP-SUVW]\d{8}$');
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el CIF de la empresa';
                  }else if (!pattern.hasMatch(value)) {
                    return 'CIF inválido. Debe comenzar con una letra y seguir con 8 dígitos.';
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el sector de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la dirección de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de teléfono';
                  }
                  final RegExp telefonoRegExp = RegExp(r'^(\+34\s?)?[6789]\d{2}(\s?\d{3}){2}$');
                  if (!telefonoRegExp.hasMatch(value)) {
                    return 'Número inválido (9 dígitos, empieza por 6, 7, 8 o 9) y español (+34 opcional)';
                  }
                  return null;
                },
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
                      CustomSnackbar.mostrar(
                          context,
                          'Ya existe una empresa con ese nombre o CIF.',
                          icono: Icons.warning_amber_rounded,
                          fondo: Colors.white,
                          texto: Colors.red,
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

                      await FirebaseFirestore.instance
                        .collection('personas')
                        .doc(widget.persona.dni)
                        .update({'empresaCif': nuevaEmpresa.cif});
                      widget.persona.empresaCif = nuevaEmpresa.cif;
                      widget.persona.esJefe = true;

                      // Muestra un mensaje de éxito
                      CustomSnackbar.mostrar(
                        context,
                        'Empresa creada con éxito',
                        icono: Icons.check_circle,
                        texto: Colors.green,
                      );

                      // Regresa a la pantalla anterior
                      Navigator.pop(context, widget.persona);
                    } catch (e) {
                      CustomSnackbar.mostrar(
                        context,
                        'Error al crear la empresa: $e',
                        icono: Icons.error_outline,
                        texto: Colors.red,
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
