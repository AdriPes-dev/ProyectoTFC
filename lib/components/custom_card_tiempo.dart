import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Tiempo extends StatefulWidget {
  const Tiempo({super.key});

  @override
  State<Tiempo> createState() => _TiempoState();
}

class _TiempoState extends State<Tiempo> {
  DateTime? horaEntrada;
  DateTime? horaSalida;
  Duration? tiempoTrabajado;

  bool estaFichado = false;

  void ficharEntrada() {
    setState(() {
      horaEntrada = DateTime.now();
      horaSalida = null;
      tiempoTrabajado = null;
      estaFichado = true;
    });
  }

  void ficharSalida() {
    if (horaEntrada != null) {
      setState(() {
        horaSalida = DateTime.now();
        tiempoTrabajado = horaSalida!.difference(horaEntrada!);
        estaFichado = false;
      });
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String horas = twoDigits(duration.inHours);
    String minutos = twoDigits(duration.inMinutes.remainder(60));
    String segundos = twoDigits(duration.inSeconds.remainder(60));
    return "$horas:$minutos:$segundos";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.blue,
          ),
        ),
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      estaFichado
                          ? "Fichado a las: ${DateFormat('HH:mm:ss').format(horaEntrada!)}"
                          : horaSalida != null
                              ? "Salida a las: ${DateFormat('HH:mm:ss').format(horaSalida!)}"
                              : "Pulsa para fichar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    if (tiempoTrabajado != null)
                      Text(
                        "Tiempo trabajado: ${formatDuration(tiempoTrabajado!)}",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: estaFichado ? null : ficharEntrada,
                          icon: Icon(Icons.play_arrow),
                          label: Text("Entrada"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF317AB2),
                            disabledBackgroundColor: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: estaFichado ? ficharSalida : null,
                          icon: Icon(Icons.stop),
                          label: Text("Salida"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF317AB2),
                            disabledBackgroundColor: Colors.grey,
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
      ],
    );
  }
}
