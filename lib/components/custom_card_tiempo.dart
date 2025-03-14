import 'package:flutter/material.dart';

class Tiempo extends StatefulWidget {
  const Tiempo({super.key});

  @override
  State<Tiempo> createState() => _TiempoState();
}

class _TiempoState extends State<Tiempo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: const Color.fromARGB(255, 49, 122, 178),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: Image.asset("assets/logoFichar.png",
                height: 150,
                width: 150,
                fit: BoxFit.cover,),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,25,0,0),
                  child: Text("08:00:00",
                  style: TextStyle(
                    fontSize: 45
                  ),),
                ),
                SizedBox(height:25),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                         color: const Color.fromARGB(255, 49, 122, 178),
                         borderRadius: BorderRadius.circular(15),
                         boxShadow: const [
                          BoxShadow(
                            blurRadius: 7.5,
                            offset: Offset(7.5, 7.5),
                            color: Color.fromARGB(255, 139, 145, 164)
                          ),
                          BoxShadow(
                            blurRadius: 7.5,
                            offset: Offset(-7.5, -7.5),
                            color: Color.fromARGB(255, 49, 122, 178),
                          ),
                         ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.access_alarm_outlined,
                        size: 40,),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.play_arrow,
                      size: 40,),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
    );
  }
}