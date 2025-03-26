import 'package:fichi/screens/menuprincipal.dart';
import 'package:fichi/screens/pantallalogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Eres nuevo?",
              style: textStyle,),
            ),
            Text("Regístrate",
            style: textStyle,),
        
            Padding(
              padding: EdgeInsets.all(30.0),
              child: TextFormCorreo(),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: TextFormContrasenya(),
            ),
            CupertinoButton(
                child: const Text("Completar Registro"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: "F i c h i")));
                },
              ),
              const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}