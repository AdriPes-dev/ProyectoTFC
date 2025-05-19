import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/components/textfieldcontrasenya.dart';
import 'package:fichi/components/textfieldcorreo.dart';
import 'package:fichi/screens/menuprincipal.dart';
import 'package:fichi/services/auth_service.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Stack(children: [ContenidoPrincipal()]),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}

class ContenidoPrincipal extends StatefulWidget {
  const ContenidoPrincipal({super.key});

  @override
  State<ContenidoPrincipal> createState() => _ContenidoPrincipalState();
}

class _ContenidoPrincipalState extends State<ContenidoPrincipal> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw "Por favor ingrese correo y contraseña";
      }

      final persona = await _authService.signInWithEmailAndPassword(email, password);
      if (persona != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(persona: persona, title: 'F I C H I',),
          ),
        );
      } else {
        throw "No se pudo iniciar sesión. Verifique sus credenciales.";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return SafeArea(
      bottom: false,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "¡Bienvenido!",
                  style:  Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.mainGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    "Inicia Sesión",
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextFormCorreo(controller: _emailController),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextFormContrasenya(controller: _passwordController),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isLoading ? null : _handleLogin,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: GradientBoxBorder(
                      gradient: AppColors.mainGradient,
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.blue)
                      : ShaderMask(
                          shaderCallback: (bounds) => AppColors.mainGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

