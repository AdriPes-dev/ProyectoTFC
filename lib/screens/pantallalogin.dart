import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/components/textfieldcontrasenya.dart';
import 'package:fichi/components/textfieldcorreo.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/menuprincipal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Stack(children: [ContenidoPrincipal()]),
      backgroundColor: Colors.white,
    );
  }
}

class ContenidoPrincipal extends StatelessWidget {
  const ContenidoPrincipal({super.key});

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
                  style: textStyle.copyWith(color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    "Inicia Sesión",
                    style: textStyle,
                    textAlign:
                        TextAlign
                            .center, // 🔹 Asegura que el texto esté centrado
                  ),
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
                padding:
                    EdgeInsets
                        .zero, // Elimina el padding por defecto para controlar mejor el diseño
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Bordes redondeados
                    border: GradientBoxBorder(
                      // Borde con degradado (necesita GradientBoxBorder)
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      width: 2, // Grosor del borde
                    ),
                  ),
                  child: ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ).createShader(bounds),
                    blendMode:
                        BlendMode.srcIn, // Aplica el gradiente solo al texto
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        color:
                            Colors
                                .white, // Importante: el color debe ser opaco para que funcione el gradiente
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(title: "F i c h i", persona: Persona(nombre: "Adrian", apellidos: "Pesquera", correo: "pesquera@gmail.com", contrasenya: "adsljfkadks", dni: "71312509G", telefono: "1234124", esJefe: false),),
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
}

