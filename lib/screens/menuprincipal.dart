
import 'dart:developer';
import 'dart:math' as math;

import 'package:fichi/main.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/paginaprincipal.dart';
import 'package:fichi/screens/pantallaempresa.dart';
import 'package:fichi/screens/paginaperfil.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.persona, required this.title});

  final String title;
  final Persona persona;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Persona persona;

  int _paginaActual = 0;

  late List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
     persona = widget.persona;
    _paginas = _buildPaginas();
  }

  List<Widget> _buildPaginas() {
  return [
    PaginaPrincipal(persona: persona),
    PantallaPerfil(persona: persona,onPersonaActualizada: _actualizarPersona),
    PantallaEmpresa(personaAutenticada: persona, onPersonaActualizada: _actualizarPersona,),
  ];
}

void _actualizarPersona(Persona nueva) {
  setState(() {
    persona = nueva;
    _paginas = _buildPaginas(); // vuelve a reconstruir las pantallas con datos nuevos
  });
}
  
  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final iconColor = isDarkMode ? Colors.white : Colors.black;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
      elevation: 0,
      centerTitle: true,
      leading: _LogoutHoldButton(),
    ),
    body: SafeArea(
      bottom: false, // Desactivamos el SafeArea en la parte inferior
      child: Stack(
        children: [
          // Contenido principal con padding inferior para el navigation bar
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Espacio para el navigation bar
            child: _paginas[_paginaActual],
          ),
          
          // Navigation bar posicionado en la parte inferior
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  final isSelected = _paginaActual == index;
                  final icon = [Icons.home, Icons.person, Icons.business][index];
                  final label = ['Inicio', 'Perfil', 'Empresa'][index];

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() => _paginaActual = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: isSelected ? AppColors.gradientPurple : iconColor,
                            ),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.gradientPurple : iconColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeOut,
                                  height: 1.5,
                                  width: isSelected ? label.length * 8.0 : 0,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gradientPurple,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
class _LogoutHoldButton extends StatefulWidget {
  @override
  State<_LogoutHoldButton> createState() => _LogoutHoldButtonState();
}

class _LogoutHoldButtonState extends State<_LogoutHoldButton> {
  bool _showHint = false;

  void _startHold() {
    setState(() => _showHint = true);
    // Trigger haptic feedback to indicate the button is ready to release
    HapticFeedback.mediumImpact();
  }

  void _endHold() async {
    setState(() => _showHint = false);

    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('dni');
    log("Se ha cerrado la sesión");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        _showHint ? Colors.grey : (isDarkMode ? Colors.white : Colors.black);

    return SizedBox(
      height: kToolbarHeight,
      child: GestureDetector(
        onTapDown: (_) => _startHold(),
        onTapUp: (_) => setState(() => _showHint = false),
        onTapCancel: () => setState(() => _showHint = false),
        onLongPressStart: (_) => _startHold(),
        onLongPressEnd: (_) => _endHold(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 48,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.logout_rounded, size: 24, color: iconColor),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: const Offset(0, 0),
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _showHint
                    ? Padding(
                        key: const ValueKey('hint-text'),
                        padding: const EdgeInsets.only(top: 4.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontSize: 12,
                              color: iconColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('no-hint'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}