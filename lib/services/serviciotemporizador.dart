import 'package:shared_preferences/shared_preferences.dart';

class TimerService {
  Future<void> guardarEstado(int horas, int minutos, int segundos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('horas', horas);
    await prefs.setInt('minutos', minutos);
    await prefs.setInt('segundos', segundos);
  }

  Future<List<int>> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt('horas') ?? 8,
      prefs.getInt('minutos') ?? 0,
      prefs.getInt('segundos') ?? 0,
    ];
  }
}
