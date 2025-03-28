import 'package:fichi/screens/pantallalogin.dart';
import 'package:fichi/screens/pantallaregistro.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF317AB2)),
      ),
      home: Stack(
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
                dotColor: const Color.fromARGB(255, 159, 166, 172),
                activeDotColor: const Color.fromARGB(255, 49, 122, 178),
              ),
              ),
          ),
        )
        ]
      )//const MyHomePage(title: 'Fichi'),
    );
  }
}
