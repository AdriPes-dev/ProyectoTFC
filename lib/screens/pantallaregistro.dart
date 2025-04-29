import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/components/textfieldcontrasenya.dart';
import 'package:fichi/components/textfieldcorreo.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/menuprincipal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenyaController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  bool _esJefe = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _contrasenyaController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text("¿Eres nuevo?", style: textStyle.copyWith(color: Colors.black)),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text("¡Regístrate!", style: textStyle),
              ),
              const SizedBox(height: 30),

              _buildCampo("Nombre", _nombreController, Icons.person),
              const SizedBox(height: 20),
              _buildCampo("Apellidos", _apellidosController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildCampo("Correo electrónico", _correoController, Icons.mail),
              const SizedBox(height: 20),
              _buildCampo("Contraseña", _contrasenyaController, Icons.lock, obscure: true),
              const SizedBox(height: 20),
              _buildCampo("DNI", _dniController, Icons.badge),
              const SizedBox(height: 20),
              _buildCampo("Teléfono", _telefonoController, Icons.phone),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _esJefe,
                    onChanged: (value) {
                      setState(() {
                        _esJefe = value ?? false;
                      });
                    },
                  ),
                  const Text("¿Eres jefe de empresa?", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 30),

              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: GradientBoxBorder(
                      gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                      width: 2,
                    ),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  final nuevaPersona = Persona(
                    nombre: _nombreController.text.trim(),
                    apellidos: _apellidosController.text.trim(),
                    correo: _correoController.text.trim(),
                    contrasenya: _contrasenyaController.text.trim(),
                    dni: _dniController.text.trim(),
                    telefono: _telefonoController.text.trim(),
                    esJefe: _esJefe,
                  );

                  // Aquí podrías guardar en SQLite o Firebase

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(title: "F i c h i", persona: nuevaPersona),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: GradientBoxBorder(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(icon, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
