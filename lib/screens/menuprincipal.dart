import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fichi/screens/paginaprincipal.dart';
import 'package:fichi/screens/pantallaempresa.dart';
import 'package:fichi/screens/pantallaperfil.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _paginaActual = 0;

  final List<Widget> _paginas = [
    PaginaPrincipal(),
    PantallaPerfil(),
    PantallaEmpresa(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 49, 122, 178),
      appBar: AppBar(
        backgroundColor: Colors.white, //Color.fromARGB(255, 65, 140, 198),
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
        backgroundColor: const Color.fromARGB(255, 49, 122, 178),
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


