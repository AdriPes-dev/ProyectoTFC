import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:intl/intl.dart';

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
  final double _cardWidth = 250;
  final double _cardHeight = 200;
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
    for (int i = 0; i < _actividades.length; i++) {
      // Calculamos la posición inversa para el degradado
      final inverseIndex = _actividades.length - 1 - i;
      final t = _actividades.length > 1 
          ? inverseIndex / (_actividades.length - 1)
          : 0.0;
          
      final color = Color.lerp(
        AppColors.primaryBlue,
        AppColors.gradientPurple, // Ahora correctamente amarillo
        t,
      )!.withOpacity(0.9);
      
      _cardColors.add(color);
    }
  });
}


  void _onCardDragged(int index, Offset delta) {
    if (index == _actividades.length - 1) {
      setState(() {
        _offsets[index] += delta;
      });
    }
  }

  void _onDragEnd(int index) {
    if (index == _actividades.length - 1) {
      if (_offsets[index].dx.abs() > 100) {
        _moverAlFondo(index);
      } else {
        _resetPosition(index);
      }
    }
  }

  void _moverAlFondo(int index) {
  setState(() {
    final actividad = _actividades.removeAt(index);
    final color = _cardColors.removeAt(index);
    
    // Insertamos al principio conservando su color
    _actividades.insert(0, actividad);
    _cardColors.insert(0, color);
    
    _offsets[index] = Offset.zero;
  });
}
  void _resetPosition(int index) {
    setState(() {
      _offsets[index] = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_actividades.isEmpty) {
      return _buildContainerMensaje("Cargando actividades...");
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      shadowColor: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Actividades", 
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            const SizedBox(height: 20),
          LayoutBuilder(
  builder: (context, constraints) {
    return SizedBox(
      height: _cardHeight * 0.6 + 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < _actividades.length; i++)
            _buildTarjetaAnimada(i, context, parentWidth: constraints.maxWidth),
        ],
      ),
    );
  },
),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaAnimada(int index, BuildContext context, {required double parentWidth}) {
  final scale = 1 - (0.1 * (_actividades.length - 1 - index));
  final verticalOffset = 20.0 * (_actividades.length - 1 - index);

  return AnimatedPositioned(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutQuad,
    top: verticalOffset + _offsets[index].dy,
    left: (parentWidth - _cardWidth) / 2 + _offsets[index].dx, // ahora centrado respecto al contenedor real
    child: Transform.scale(
      scale: scale,
      child: GestureDetector(
        onPanUpdate: (details) => _onCardDragged(index, details.delta),
        onPanEnd: (details) => _onDragEnd(index),
        child: _buildActivityCard(_actividades[index], context, index: index),
      ),
    ),
  );
}

 Widget _buildActivityCard(Actividad actividad, BuildContext context, {required int index}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final shadowColor = isDarkMode ? Colors.white : Colors.black;
  final Color cardColor = _cardColors[index % _cardColors.length];
  final fechaFormatted = DateFormat('dd-MM-yyyy – HH:mm').format(actividad.fechaActividad);

  // Crear el evento para añadir
  final Event event = Event(
    title: actividad.titulo,
    description: 'Evento generado desde la app',
    location: '', // Si tienes ubicación, pon aquí
    startDate: actividad.fechaActividad,
    endDate: actividad.fechaActividad.add(Duration(hours: 1)), // 1 hora por defecto
  );

  return GestureDetector(
    onTap: () {
      Add2Calendar.addEvent2Cal(event);
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      shadowColor: shadowColor,
      child: Container(
        width: _cardWidth,
        height: _cardHeight * 0.6,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.event_note, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    actividad.titulo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fechaFormatted,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildContainerMensaje(String mensaje) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          mensaje,
          style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}