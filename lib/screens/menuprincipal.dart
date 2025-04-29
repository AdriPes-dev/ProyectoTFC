import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/paginaprincipal.dart';
import 'package:fichi/screens/pantallaempresa.dart';
import 'package:fichi/screens/pantallaperfil.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.persona, required this.title});

  final String title;
  final Persona persona;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _paginaActual = 0;

  late final List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    _paginas = [
      PaginaPrincipal(persona: widget.persona),
      PantallaPerfil(persona: widget.persona),
      PantallaEmpresa(personaAutenticada: widget.persona),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue, //Color.fromARGB(255, 65, 140, 198),
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.logout_rounded),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue,
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


