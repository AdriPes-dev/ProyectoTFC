import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/empresa.dart';

class UnirseAEmpresaScreen extends StatefulWidget {
  final Persona persona;

  const UnirseAEmpresaScreen({super.key, required this.persona});

  @override
  State<UnirseAEmpresaScreen> createState() => _UnirseAEmpresaScreenState();
}

class _UnirseAEmpresaScreenState extends State<UnirseAEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cifController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unirse a una Empresa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cifController,
                decoration: InputDecoration(labelText: 'CIF de la Empresa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el CIF de la empresa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Buscar la empresa por CIF
                    // Aquí deberías buscar la empresa por el CIF, este es solo un ejemplo
                    final empresa = Empresa(
                      cif: _cifController.text,
                      nombre: 'Empresa Ejemplo', // Nombre de ejemplo
                      direccion: 'Dirección Ejemplo',
                      telefono: '123456789',
                      email: 'empresa@ejemplo.com',
                      sector: 'Tecnología',
                      jefe: Persona(dni: 'Jefe123', nombre: 'Jefe Ejemplo', empresa: null, apellidos: 'Ej', correo: 'dasada', contrasenya: 'adasdad', telefono: '2131413'),
                    );

                    // Asignar la empresa a la persona
                    setState(() {
                      widget.persona.empresa = empresa;
                    });

                    // Navegar a la pantalla de empresa
                    Navigator.pop(context);
                  }
                },
                child: Text('Unirse a la Empresa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
