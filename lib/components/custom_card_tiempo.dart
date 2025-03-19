import 'package:flutter/material.dart' hide BoxDecoration,BoxShadow;
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
      behavior: HitTestBehavior.opaque, // Solo detecta clics en áreas vacías
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
                child: TextoHora(),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!presionStop) {
                          presionStop = !presionStop;
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
                        child: Icon(
                          Icons.coffee,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 25),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!presionPlay) {
                          presionPlay = !presionPlay;
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
                        child: Icon(
                          Icons.play_arrow,
                          size: 40,
                        ),
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
  const TextoHora({
    super.key,
  });
  
  @override
  State<StatefulWidget> createState() => _TextoHoraState();
}
class _TextoHoraState extends State<TextoHora>{
  @override
  Widget build(BuildContext context) {
    return Text(
      "08:00:00",
      style: TextStyle(fontSize: 45),
      );
  }}