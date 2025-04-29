import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/empresa.dart';

class CrearEmpresaScreen extends StatefulWidget {
  final Persona persona;

  const CrearEmpresaScreen({super.key, required this.persona});

  @override
  State<CrearEmpresaScreen> createState() => _CrearEmpresaScreenState();
}

class _CrearEmpresaScreenState extends State<CrearEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crear Empresa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la Empresa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la empresa';
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
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Crear una nueva empresa
                    final nuevaEmpresa = Empresa(
                      cif: 'CIF${DateTime.now().millisecondsSinceEpoch}', // Generación de CIF
                      nombre: _nombreController.text,
                      direccion: _direccionController.text,
                      telefono: _telefonoController.text,
                      email: _emailController.text,
                      sector: _sectorController.text,
                      jefe: widget.persona, // La persona que crea la empresa es el jefe
                    );
                    
                    // Asignar la empresa a la persona autenticada
                    setState(() {
                      widget.persona.empresa = nuevaEmpresa;
                    });

                    // Navegar de vuelta a la pantalla de empresa
                    Navigator.pop(context);
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
