
import 'dart:developer';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fichi/main.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/paginaprincipal.dart';
import 'package:fichi/screens/pantallaempresa.dart';
import 'package:fichi/screens/paginaperfil.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.persona, required this.title});

  final String title;
  final Persona persona;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Persona persona;

  int _paginaActual = 0;

  late List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
     persona = widget.persona;
    _paginas = _buildPaginas();
  }

  List<Widget> _buildPaginas() {
  return [
    PaginaPrincipal(persona: persona),
    PantallaPerfil(persona: persona,onPersonaActualizada: _actualizarPersona),
    PantallaEmpresa(personaAutenticada: persona),
  ];
}

void _actualizarPersona(Persona nueva) {
  setState(() {
    persona = nueva;
    _paginas = _buildPaginas(); // vuelve a reconstruir las pantallas con datos nuevos
  });
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent, //Color.fromARGB(255, 65, 140, 198),
        title: Text(
          widget.title,
          style:  Theme.of(context).textTheme.titleMedium,),
        elevation: 0,
        centerTitle: true,
       leading: IconButton(
  onPressed: () async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dni');
    log("Se ha cerrado la sesion");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MyApp(), // ← Reemplaza con el nombre real de tu pantalla de login
      ),
      (route) => false, // Elimina todo lo anterior en el stack de navegación
    );
  },
  icon: const Icon(Icons.logout_rounded),
),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: AppColors.primaryBlue,
        buttonBackgroundColor: AppColors.primaryBlue,
        animationDuration: Duration(milliseconds: 100),
        items: [Icon(Icons.home), Icon(Icons.person), Icon(Icons.business)],
        onTap: (index) {
          setState(() {
             _paginaActual = index;
          });
        },
      ),
      body: _paginas[_paginaActual],
    );
  }
}


