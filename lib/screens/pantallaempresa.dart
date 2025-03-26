import 'package:flutter/material.dart';

class PantallaEmpresa extends StatefulWidget {
  const PantallaEmpresa({super.key});

  @override
  State<PantallaEmpresa> createState() => _PantallaEmpresaState();
}

class _PantallaEmpresaState extends State<PantallaEmpresa> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(25.0), child: Text("Empresa")),
        ],
      ),
    );
  }
}