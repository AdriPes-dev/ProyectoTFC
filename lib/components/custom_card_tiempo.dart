import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/databasehelper.dart';
import 'package:fichi/model_classes/fichaje.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TimeTracker extends StatefulWidget {

  final Persona persona;

  const TimeTracker({super.key, required this.persona});

  @override
  State<TimeTracker> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _workedDuration;
  bool _isClockedIn = false;

  @override
  void initState() {
    super.initState();
    _restaurarFichaje();
    _listenToConnectivityChanges();
  }

  void _listenToConnectivityChanges() {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
    if (result.isNotEmpty && result.first != ConnectivityResult.none) {
      print("Conexión recuperada, sincronizando fichajes...");
      await DatabaseHelper.instance.sincronizarFichajesPendientes();
    }
  });
}
 Future<void> _guardarInicioFichaje(DateTime inicio) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'fichaje_entrada_${widget.persona.dni}';
  await prefs.setString(key, inicio.toIso8601String());
}

  Future<DateTime?> _obtenerInicioFichaje() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'fichaje_entrada_${widget.persona.dni}';
  final entradaStr = prefs.getString(key);
  if (entradaStr != null) {
    return DateTime.tryParse(entradaStr);
  }
  return null;
}

 Future<void> _limpiarInicioFichaje() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'fichaje_entrada_${widget.persona.dni}';
  await prefs.remove(key);
}

  Future<void> _restaurarFichaje() async {
    final entrada = await _obtenerInicioFichaje();
    if (entrada != null) {
      setState(() {
        _startTime = entrada;
        _isClockedIn = true;
      });
    }
  }

  void _clockIn() async {
  // Validar si la persona tiene empresa asociada
  if (widget.persona.empresaCif == null || widget.persona.empresaCif!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No puedes fichar si no estás vinculado a una empresa.'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  final ahora = DateTime.now();
  setState(() {
    _startTime = ahora;
    _endTime = null;
    _workedDuration = null;
    _isClockedIn = true;
  });
  await _guardarInicioFichaje(ahora);
}

  void _clockOut() async {
    if (_startTime != null) {
      final salida = DateTime.now();
      final duracion = salida.difference(_startTime!);

      setState(() {
        _endTime = salida;
        _workedDuration = duracion;
        _isClockedIn = false;
      });

      await _limpiarInicioFichaje();

      final fichaje = Fichaje(
        id: Uuid().v4(),
        dniEmpleado: widget.persona.dni,
        cifEmpresa: widget.persona.empresaCif ?? "sin_cif",
        entrada: _startTime!,
        salida: salida,
        duracion: duracion,
      );

      await DatabaseHelper.instance.guardarFichaje(fichaje);
    }
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.white : Colors.black;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Card(
      elevation: 10,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Column(
              children: [
                Icon(Icons.access_time, color: AppColors.primaryBlue, size: 40),
                const SizedBox(width: 15),
                Text(
                  'Registro de Tiempo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Time Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _isClockedIn 
                        ? 'Entrada: ${DateFormat('HH:mm:ss').format(_startTime!)}'
                        : _endTime != null
                            ? 'Salida: ${DateFormat('HH:mm:ss').format(_endTime!)}'
                            : 'Presiona Entrada para comenzar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                  if (_workedDuration != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tiempo trabajado: ${_formatDuration(_workedDuration!)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: FilledButton.icon(
              onPressed: _isClockedIn ? null : _clockIn,
              icon: Icon(Icons.play_arrow , color: textColor,),
              label: Text('Entrada', style: TextStyle( color: textColor),),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isClockedIn ? _clockOut : null,
                    icon: Icon(Icons.stop, color: textColor,),
                    label: Text('Salida', style: TextStyle( color: textColor),),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gradientPurple,
                      disabledBackgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }