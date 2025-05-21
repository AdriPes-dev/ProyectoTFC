import 'package:fichi/firebase_options.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/menuprincipal.dart';
import 'package:fichi/screens/pantallalogin.dart';
import 'package:fichi/screens/pantallaregistro.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );

   SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dni = prefs.getString('dni');

  Persona? persona;
  if (dni != null) {
    persona = await FirebaseService().obtenerPersonaPorDni(dni);
  }

  runApp(MyApp(personaAutenticada: persona,));
}

class MyApp extends StatefulWidget {
  final Persona? personaAutenticada;
  const MyApp({super.key, this.personaAutenticada});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final controller = LiquidController();

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fichi',
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
       home: widget.personaAutenticada != null
          ? MyHomePage(persona: widget.personaAutenticada!, title: 'F I C H I')
          : Stack(
        children:[ LiquidSwipe(
          onPageChangeCallback: (activePageIndex) {
            setState(() {
            });
          },
          liquidController: controller,
          pages: [
            PageLogin(),
            PantallaRegistro(),
          ],
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSmoothIndicator(
              activeIndex: controller.currentPage, 
              count: 2,
              effect: WormEffect(
                spacing: 12,
                dotColor: AppColors.gradientPurple,
                activeDotColor: AppColors.primaryBlue,
              ),
              ),
          ),
        )
        ]
      )//const MyHomePage(title: 'Fichi'),
    );
  }
}
