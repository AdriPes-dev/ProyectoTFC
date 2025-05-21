import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:intl/intl.dart';
import '../model_classes/actividad.dart';

class VerticalStackedCards extends StatefulWidget {
  final List<Actividad> actividades;
  final List<Color> cardColors;
  final double cardHeight;
  final double cardWidth;

  const VerticalStackedCards({
    super.key,
    required this.actividades,
    required this.cardColors,
    this.cardHeight = 250,
    this.cardWidth = 300,
  });

  @override
  State<VerticalStackedCards> createState() => _VerticalStackedCardsState();
}

class _VerticalStackedCardsState extends State<VerticalStackedCards> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  double _currentPage = 0;
  final double _perspectiveValue = 0.001;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _currentPage = _pageController.page!);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addToCalendar(Actividad actividad) {
    final event = Event(
      title: actividad.titulo,
      description: 'Añadido desde la app',
      startDate: actividad.fechaActividad,
      endDate: actividad.fechaActividad.add(const Duration(hours: 1)),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.cardHeight * 1.5,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.actividades.length,
        itemBuilder: (context, index) {
          final diferencia = index - _currentPage;
          final valorEscala = 1 - (diferencia.abs() * 0.1);
          final desplazamientoY = diferencia * 40;
          final opacidad = (1 - diferencia.abs() * 0.3).clamp(0.4, 1.0);
          final rotacionX = diferencia * 0.05;

          return GestureDetector(
            onTap: () => diferencia == 0 
                ? _addToCalendar(widget.actividades[index])
                : _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspectiveValue)
                ..rotateX(rotacionX)
                ..translate(0.0, desplazamientoY)
                ..scale(valorEscala),
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: opacidad,
                child: _TarjetaApilada(
                  actividad: widget.actividades[index],
                  color: widget.cardColors[index % widget.cardColors.length],
                  height: widget.cardHeight,
                  width: widget.cardWidth,
                  isFront: diferencia == 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaApilada extends StatelessWidget {
  final Actividad actividad;
  final Color color;
  final double height;
  final double width;
  final bool isFront;

  const _TarjetaApilada({
    required this.actividad,
    required this.color,
    required this.height,
    required this.width,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                actividad.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Descripción
              Text(
                actividad.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),

              const Spacer(),

              // Fecha y hora
              Row(
                children: [
                  const Icon(Icons.access_time,),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(actividad.fechaActividad),
                    style: const TextStyle(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Botón para añadir al calendario
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Añadir al calendario'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Add2Calendar.addEvent2Cal(
                  Event(
                    title: actividad.titulo,
                    description: actividad.descripcion,
                    startDate: actividad.fechaActividad,
                    endDate: actividad.fechaActividad.add(const Duration(hours: 1)),
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
