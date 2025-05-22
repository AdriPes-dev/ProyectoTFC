
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
  late PageController _pageController;  // <-- Añadido

  @override
  void initState() {
    super.initState();
    persona = widget.persona;
    _paginas = _buildPaginas();
    _pageController = PageController(initialPage: _paginaActual); // Inicializamos controlador
  }

  @override
  void dispose() {
    _pageController.dispose();  // Liberamos controlador
    super.dispose();
  }

  List<Widget> _buildPaginas() {
    return [
      PaginaPrincipal(persona: persona),
      PantallaPerfil(persona: persona, onPersonaActualizada: _actualizarPersona),
      PantallaEmpresa(personaAutenticada: persona, onPersonaActualizada: _actualizarPersona),
    ];
  }

  void _actualizarPersona(Persona nueva) {
    setState(() {
      persona = nueva;
      _paginas = _buildPaginas();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _paginaActual = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final iconColor = isDarkMode ? Colors.white : Colors.black;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      title: Text(widget.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 18,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: _LogoutHoldButton(),
      ),
      leadingWidth: 56,
    ),
    body: Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _paginas,
          physics: const BouncingScrollPhysics(),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue, // fondo azul
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
                    onTap: () => _onItemTapped(index),
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
  );
}
}
class _LogoutHoldButton extends StatefulWidget {
  @override
  State<_LogoutHoldButton> createState() => _LogoutHoldButtonState();
}

class _LogoutHoldButtonState extends State<_LogoutHoldButton> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isReadyToLogout = false; // Para saber si llegó al máximo color rojo

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  getIsPressed() {
    return _isPressed;
  } 

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // duración del progreso
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isReadyToLogout = true;
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _isReadyToLogout = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _colorAnimation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: AppColors.gradientPurple,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    setState(() {
      _isPressed = true;
      _isReadyToLogout = false;
    });
    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  void _endHold() async {
    if (_isReadyToLogout) {
      // Cierre de sesión al haber completado el progreso
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('dni');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MyApp()),
        (route) => false,
      );
    } else {
      await _controller.reverse();
      setState(() {
        _isPressed = false;
        _isReadyToLogout = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: kToolbarHeight,
      child: Tooltip(
        message: 'Mantén presionado para cerrar sesión',
        child: GestureDetector(
          onLongPressStart: (_) => _startHold(),
          onLongPressEnd: (_) => _endHold(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.logout_rounded,
                  color: _colorAnimation.value,
                  size: 24,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}