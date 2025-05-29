import 'package:fichi/components/custom_perspectiva.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/actividad.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';

class ActividadRecienteCard extends StatefulWidget {
  final Persona p;

  const ActividadRecienteCard({super.key, required this.p});

  @override
  State<ActividadRecienteCard> createState() => _ActividadRecienteCardState();
}

class _ActividadRecienteCardState extends State<ActividadRecienteCard> with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  List<Actividad> _actividades = [];
  final List<Offset> _offsets = [];
  final List<Color> _cardColors = [];
  
  bool _sinEmpresa = false; // <-- Añadido

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  Future<void> _cargarActividades() async {
  final empresaCif = widget.p.empresaCif;

  if (empresaCif == null) {
    if (!mounted) return; // Verifica si el widget sigue montado
    setState(() {
      _sinEmpresa = true;
      _actividades = [];
      _offsets.clear();
      _cardColors.clear();
    });
    return;
  }

  final actividades = await _firebaseService.obtenerActividadesFuturas(empresaCif);

  if (!mounted) return; // Verifica si el widget sigue montado
  setState(() {
    _sinEmpresa = false;
    _actividades = actividades;
    _offsets.clear();
    _offsets.addAll(List.filled(_actividades.length, Offset.zero));

    _cardColors.clear();
    for (int i = 0; i < actividades.length; i++) {
      final t = actividades.length > 1 ? i / (actividades.length - 1) : 0.0;
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Card(
      elevation: 0,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Theme.of(context).cardColor,
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.4), // Sombra azul
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.event, color: AppColors.primaryBlue, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Actividades',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contenedor para las tarjetas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_actividades.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        _sinEmpresa
                            ? 'Primero regístrate en una empresa'
                            : 'No hay actividades programadas',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    VerticalStackedCards(
                      actividades: _actividades,
                      cardColors: _cardColors,
                      cardHeight: 200,
                      cardWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}