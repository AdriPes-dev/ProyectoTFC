import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeTracker extends StatefulWidget {
  const TimeTracker({super.key});

  @override
  State<TimeTracker> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _workedDuration;
  bool _isClockedIn = false;

  void _clockIn() {
    setState(() {
      _startTime = DateTime.now();
      _endTime = null;
      _workedDuration = null;
      _isClockedIn = true;
    });
  }

  void _clockOut() {
    if (_startTime != null) {
      setState(() {
        _endTime = DateTime.now();
        _workedDuration = _endTime!.difference(_startTime!);
        _isClockedIn = false;
      });
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
    final shadowColor = isDarkMode ? Colors.white54 : Colors.black26;
    
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
                color: Colors.white.withOpacity(0.2),
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
                      color: Colors.black,
                    ),
                  ),
                  if (_workedDuration != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tiempo trabajado: ${_formatDuration(_workedDuration!)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textBlack,
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
              icon: const Icon(Icons.play_arrow , color: AppColors.gradientPurple,),
              label: const Text('Entrada', style: TextStyle( color: AppColors.gradientPurple),),
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
                    icon: const Icon(Icons.stop, color: AppColors.primaryBlue,),
                    label: const Text('Salida', style: TextStyle( color: AppColors.primaryBlue),),
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