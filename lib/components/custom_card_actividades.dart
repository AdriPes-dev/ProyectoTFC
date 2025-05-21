import 'package:fichi/components/custom_perspectiva.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';

class ActividadRecienteCard extends StatefulWidget {
  final Persona p;

  const ActividadRecienteCard({Key? key, required this.p}) : super(key: key);

  @override
  State<ActividadRecienteCard> createState() => _ActividadRecienteCardState();
}

class _ActividadRecienteCardState extends State<ActividadRecienteCard> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  List<Actividad> _actividades = [];
  final List<Offset> _offsets = [];
  final List<Color> _cardColors = [];

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // En el método _cargarActividades
Future<void> _cargarActividades() async {
  final actividades = await _firebaseService.obtenerActividadesRecientes(widget.p.empresaCif!);
  
  setState(() {
    _actividades = actividades;
    _offsets.addAll(List.filled(_actividades.length, Offset.zero));

    _cardColors.clear();
    for (int i = 0; i < actividades.length; i++) {
  final t = actividades.length > 1 
      ? i / (actividades.length - 1)
      : 0.0;

  final color = Color.lerp(
    AppColors.primaryBlue,
    AppColors.gradientPurple,
    t,
  )!.withOpacity(0.9);

  _cardColors.add(color);
}
  });
}

@override
Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.all(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividades',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          VerticalStackedCards(
            actividades: _actividades,
            cardColors: _cardColors,
            cardHeight: 250,
            cardWidth: MediaQuery.of(context).size.width * 0.9,
          ),
        ],
      ),
    ),
  );
}

}