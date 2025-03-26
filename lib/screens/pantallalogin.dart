import 'package:fichi/screens/menuprincipal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Stack(
      children: [
          ContenidoPrincipal()
      ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

class ContenidoPrincipal extends StatelessWidget {
  const ContenidoPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black);

    return SafeArea(
      bottom: false,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Bienvenido a Fichi\nRellena el Inicio de Sesión",
                  style: textStyle,
                  textAlign: TextAlign.center, // 🔹 Asegura que el texto esté centrado
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: TextFormCorreo(),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: const TextFormContrasenya(),
              ),
              CupertinoButton(
                child: const Text("Iniciar Sesión"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: "F i c h i")));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFormCorreo extends StatelessWidget {
  const TextFormCorreo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(8.0),
        filled: true,
        labelText: "Introduce tu correo electrónico",
        border: OutlineInputBorder(),
        fillColor: Colors.white,
      ),
    );
  }
}

class TextFormContrasenya extends StatefulWidget {
  const TextFormContrasenya({super.key});

  @override
  State<TextFormContrasenya> createState() => _EstadosContrasenya();
}

class _EstadosContrasenya extends State<TextFormContrasenya> {
  bool _estadoContrasenya = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_estadoContrasenya,
      decoration: InputDecoration(
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(8.0),
        filled: true,
        labelText: "Introduce tu contraseña",
        suffixIcon: IconButton(
          icon: Icon(_estadoContrasenya ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _estadoContrasenya = !_estadoContrasenya;
            });
          },
        ),
      ),
    );
  }
}
