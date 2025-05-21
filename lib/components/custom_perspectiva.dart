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
  int? _expandedIndex;
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

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

  void _showExpandedCard(int index) {
  final actividad = widget.actividades[index];
  final color = widget.cardColors[index % widget.cardColors.length];

  // Encuentra la posición en pantalla de la tarjeta tocada
  final box = context.findRenderObject() as RenderBox;
  final origenGlobal = box.localToGlobal(Offset.zero);
  final size = Size(widget.cardWidth, widget.cardHeight);

  final origenRect = Rect.fromLTWH(
    origenGlobal.dx + 40, // ajusta si tus tarjetas no están centradas
    origenGlobal.dy + (index - _currentPage).toDouble() * 40,
    size.width,
    size.height,
  );

  _overlayEntry = OverlayEntry(
    builder: (_) => _OverlayTarjetaExpandida(
      origen: origenRect,
      actividad: actividad,
      color: color,
      onClose: _removeOverlay,
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
  _isOverlayVisible = true;
}

void _removeOverlay() {
  if (_overlayEntry != null && _isOverlayVisible) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
  }
}

  Widget _buildIndicator(int index, bool isActive, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 8,
      height: isActive ? 24 : 12,
      decoration: BoxDecoration(
        color: isActive 
            ? (isDarkMode ? Colors.white : Colors.black)
            : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  

  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return SizedBox(
    height: widget.cardHeight * 1.5,
    child: Stack(
      children: [
        // Indicadores izquierdos
        Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.actividades.length, (index) {
              return _buildIndicator(
                index,
                index == _currentPage.round(),
                isDarkMode,
              );
            }),
          ),
        ),

        // PageView principal
        PageView.builder(
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
              onTap: () {
  if (diferencia == 0 && !_isOverlayVisible) {
    _showExpandedCard(index); // 👉 muestra la tarjeta en pantalla completa
  } else {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
},
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

        // Indicadores derechos
        Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.actividades.length, (index) {
              return _buildIndicator(
                index,
                index == _currentPage.round(),
                isDarkMode,
              );
            }),
          ),
        ),

        // Tarjeta expandida animada
        if (_isExpanded && _expandedIndex != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = false;
                  _expandedIndex = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: AnimatedScale(
                  scale: _isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _TarjetaExpandida(
                    actividad: widget.actividades[_expandedIndex!],
                    color: widget.cardColors[_expandedIndex! % widget.cardColors.length],
                  ),
                ),
              ),
            ),
          ),
      ],
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
      constraints: BoxConstraints(
        minHeight: height,
        maxHeight: height, // Altura fija
        minWidth: width,
        maxWidth: width,   // Ancho fijo
      ),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
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
            mainAxisSize: MainAxisSize.min, // Evita expansión innecesaria
            children: [
              // Título (con límite de una línea)
              SizedBox(
                height: 28, // Altura fija para título
                child: Text(
                  actividad.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Descripción (limitada a una línea)
              SizedBox(
                height: 20, // Altura fija para descripción
                child: Text(
                  actividad.descripcion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Fecha y hora (altura fija)
              SizedBox(
                height: 24,
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(actividad.fechaActividad),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botón (altura fija)
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text(
                    'Añadir al calendario',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: textColor,
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _TarjetaExpandida extends StatelessWidget {
  final Actividad actividad;
  final Color color;

  const _TarjetaExpandida({
    required this.actividad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Material(
      borderRadius: BorderRadius.circular(20),
      color: color,
      elevation: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(
          maxHeight: 500,
          maxWidth: 350,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              actividad.titulo,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Text(
              actividad.descripcion,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(actividad.fechaActividad),
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text("Añadir al calendario"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: textColor,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                onPressed: () {
                  Add2Calendar.addEvent2Cal(
                    Event(
                      title: actividad.titulo,
                      description: actividad.descripcion,
                      startDate: actividad.fechaActividad,
                      endDate: actividad.fechaActividad.add(const Duration(hours: 1)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _OverlayTarjetaExpandida extends StatefulWidget {
  final Rect origen;
  final Actividad actividad;
  final Color color;
  final VoidCallback onClose;

  const _OverlayTarjetaExpandida({
    required this.origen,
    required this.actividad,
    required this.color,
    required this.onClose,
  });

  @override
  State<_OverlayTarjetaExpandida> createState() => _OverlayTarjetaExpandidaState();
}

class _OverlayTarjetaExpandidaState extends State<_OverlayTarjetaExpandida>
    with SingleTickerProviderStateMixin {
  late Rect destino;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Aquí ya se puede usar MediaQuery
    destino = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
    );

    _controller.forward(); // comienza animación aquí
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;
    return GestureDetector(
      onTap: widget.onClose,
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final rect = Rect.lerp(widget.origen, destino, _controller.value)!;
                return Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.color,
                    elevation: 10,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.actividad.titulo,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: shadowColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.actividad.descripcion,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: shadowColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Botón de cerrar
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: widget.onClose,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}