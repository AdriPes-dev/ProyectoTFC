import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/menuprincipal.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fichi/services/auth_service.dart';

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
  final AuthService _authService = AuthService();
  bool _isLoading = false;

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

  // Método para manejar el registro
  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    // Validación de campos
    if (_nombreController.text.isEmpty ||
        _apellidosController.text.isEmpty ||
        _correoController.text.isEmpty ||
        !_correoController.text.contains('@') ||
        _dniController.text.isEmpty ||
        _contrasenyaController.text.isEmpty) {
      setState(() => _isLoading = false);
      CustomSnackbar.mostrar(
        context,
        'Por favor, completa todos los campos',
        icono: Icons.error_outline,
        texto: Colors.red,
      );
      return;
    }

    try {
      // Validación de contraseña
      if (_contrasenyaController.text.length < 6) {
        throw "La contraseña debe tener al menos 6 caracteres";
      }

      // Crear nueva persona
      final nuevaPersona = Persona(
        dni: _dniController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        correo: _correoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        esJefe: false, // Por defecto no es jefe
      );

      // Registrar en Firebase
      final user = await _authService.registerWithEmailAndPassword(
        nuevaPersona.correo,
        _contrasenyaController.text.trim(),
        nuevaPersona,
      );

      if (user != null) {
        // Navegar a pantalla principal después de registro exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: "F i c h i", 
              persona: nuevaPersona,
            ),
          ),
        );
      }
    } catch (e) {
      CustomSnackbar.mostrar(
        context,
        'Error al crear el usuario',
        icono: Icons.error_outline,
        texto: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text("¿Eres nuevo?", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  ),),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.mainGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
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
              const SizedBox(height: 30),

              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isLoading ? null : _handleRegister,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: GradientBoxBorder(
                      gradient: AppColors.mainGradient,
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blue))
                      : ShaderMask(
                          shaderCallback: (bounds) => AppColors.mainGradient.createShader(bounds),
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
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 30),
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
          gradient: AppColors.mainGradient,
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(icon, color: Colors.grey[600]),
        ),
      ),
    );
  }
}