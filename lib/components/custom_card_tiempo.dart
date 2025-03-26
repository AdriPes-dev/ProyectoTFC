import 'dart:async';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class Tiempo extends StatefulWidget {
  const Tiempo({super.key});

  @override
  State<Tiempo> createState() => _TiempoState();
}

class _TiempoState extends State<Tiempo> {
  bool presionPlay = false;
  bool presionStop = true;
  bool presionContenedor = false;

  @override
  Widget build(BuildContext context) {
    double blurStop = presionStop ? 7.5 : 2.5;
    double blurPlay = presionPlay ? 7.5 : 2.5;
    double blurContenedor = presionContenedor ? 7.5 : 2.5;

    return Stack(
      children: [
        // Fondo (solo responde si no tocas los botones)
        Listener(
          behavior:
              HitTestBehavior.opaque, // Solo detecta clics en áreas vacías
          onPointerDown: (event) {
            setState(() {
              presionContenedor = !presionContenedor;
            });
          },
          onPointerUp: (event) {
            setState(() {
              presionContenedor = !presionContenedor;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: const Color.fromARGB(255, 49, 122, 178),
              boxShadow: [
                BoxShadow(
                  blurRadius: blurContenedor,
                  offset: Offset(7.5, 7.5),
                  color: Color(0xFF1E4D73),
                  inset: presionContenedor,
                ),
                BoxShadow(
                  blurRadius: blurContenedor,
                  offset: Offset(-7.5, -7.5),
                  color: Color(0xFF5FADE6),
                  inset: presionContenedor,
                ),
              ],
            ),
          ),
        ),

        // Contenido (botones y demás)
        Positioned.fill(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Listener(
                  onPointerDown: (event) {
                    setState(() {
                      presionContenedor = !presionContenedor;
                    });
                  },
                  onPointerUp: (event) {
                    setState(() {
                      presionContenedor = !presionContenedor;
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/logoFichar.png",
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    child: TextoHora(key: TextoHora.globalKey),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!presionStop) {
                              presionStop = !presionStop;
                              TextoHora.globalKey.currentState?.stopTimer();
                            }
                            if (presionStop) {
                              presionPlay = false;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 50),
                          decoration: BoxDecoration(
                            color: const Color(0xFF317AB2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: blurStop,
                                offset: Offset(7.5, 7.5),
                                color: Color(0xFF1E4D73),
                                inset: presionStop,
                              ),
                              BoxShadow(
                                blurRadius: blurStop,
                                offset: Offset(-7.5, -7.5),
                                color: Color(0xFF5FADE6),
                                inset: presionStop,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.coffee, size: 40),
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!presionPlay) {
                              presionPlay = !presionPlay;
                              TextoHora.globalKey.currentState?.startTimer();
                            }
                            if (presionPlay) {
                              presionStop = false;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          decoration: BoxDecoration(
                            color: const Color(0xFF317AB2),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: blurPlay,
                                offset: Offset(7.5, 7.5),
                                color: Color(0xFF1E4D73),
                                inset: presionPlay,
                              ),
                              BoxShadow(
                                blurRadius: blurPlay,
                                offset: Offset(-7.5, -7.5),
                                color: Color(0xFF5FADE6),
                                inset: presionPlay,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.play_arrow, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TextoHora extends StatefulWidget {
  const TextoHora({super.key});

  // Clave global para acceder al estado del widget desde fuera
  static final GlobalKey<_TextoHoraState> globalKey = GlobalKey();

  @override
  State<TextoHora> createState() => _TextoHoraState();
}

class _TextoHoraState extends State<TextoHora> {
  int segundos = 0;
  int minutos = 0;
  int horas = 8; // Inicializado correctamente a 8 horas
  Timer? timer;

  /// Inicia el temporizador
  void startTimer() {
    if (timer != null && timer!.isActive) return; // Evita múltiples timers

    if (!mounted) {
      timer?.cancel();
      return;
    }


    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (horas == 0 && minutos == 0 && segundos == 0) {
          timer.cancel(); // Detiene el contador si llega a 00:00:00
        } else if (segundos > 0) {
          segundos--;
        } else if (minutos > 0) {
          minutos--;
          segundos = 59;
        } else if (horas > 0) {
          horas--;
          minutos = 59;
          segundos = 59;
        }
      });
    });
  }

  /// Detiene el temporizador
  void stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel(); // Evita errores al salir de la pantalla
    super.dispose();
  }


  /// Formatea los números para que siempre tengan dos dígitos
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Text(
      "${twoDigits(horas)}:${twoDigits(minutos)}:${twoDigits(segundos)}",
      style: const TextStyle(fontSize: 30),
    );
  }
}
/*
class TextoHora extends StatefulWidget {
  const TextoHora({
    super.key,
  });
  
  @override
  State<StatefulWidget> createState() => _TextoHoraState();
}
class _TextoHoraState extends State<TextoHora>{

  int segundos = 0;
  int minutos = 0;
  int horas = 8;
  Timer? timer;
  
  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    return Text(
      "$horas:$minutos:$segundos",
      style: TextStyle(fontSize: 45),
      );
  }}*/