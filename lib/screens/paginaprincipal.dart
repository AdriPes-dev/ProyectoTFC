import 'package:fichi/components/custom_card_tiempo.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:flutter/material.dart';

class PaginaPrincipal extends StatelessWidget {

  final Persona persona;

  const PaginaPrincipal({
    super.key,
    required this.persona
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(padding: const EdgeInsets.all(25.0), child: Tiempo()),
        ],
      ),
    );
  }
}