import 'package:fichi/components/estado_circular.dart';
import 'package:flutter/material.dart';
/*
class EstadisticasSemanalesScreen extends StatefulWidget {
  final int diasTrabajados;
  final int totalDias;
  final List<bool> dias;
  final double horasTrabajadas;
  final double horasTotales;
  final int numeroIncidencias;

  const EstadisticasSemanalesScreen({
    super.key,
    required this.diasTrabajados,
    required this.totalDias,
    required this.dias,
    required this.horasTrabajadas,
    required this.horasTotales,
    required this.numeroIncidencias,
  });

  @override
  State<EstadisticasSemanalesScreen> createState() => _EstadisticasSemanalesScreenState();
}

class _EstadisticasSemanalesScreenState extends State<EstadisticasSemanalesScreen> with SingleTickerProviderStateMixin {

  Widget _buildDiasTrabajadosRow() {
  const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(widget.dias.length, (index) {
      final trabajado = widget.dias[index];
      final letra = diasSemana[index % 7];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: trabajado ? Colors.green : Colors.red,
          child: Text(
            letra,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Estadísticas de esta semana",style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
            SizedBox(height: 60),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Horas trabajadas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                EstadoCircularHoras(horasTrabajadas: widget.horasTrabajadas,horasTotales: widget.horasTotales,),
                const SizedBox(height: 10),
                const Text("Días trabajados", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _buildDiasTrabajadosRow(),
                const SizedBox(height: 40),
                    const Text("Incidencias que has registrado", style: TextStyle(fontSize: 18)),

                EstadoCircularIncidencias(incidencias: widget.numeroIncidencias),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
class EstadisticasScreen extends StatefulWidget {
  final int diasTrabajados;
  final int totalDias;
  final List<bool> dias;
  final double horasSemanales;
  final double horasMensuales;
  final double horasTotales;
  final int incidenciasSemanales;
  final int incidenciasMensuales;
  final int incidenciasTotales;

  const EstadisticasScreen({
    super.key,
    required this.diasTrabajados,
    required this.totalDias,
    required this.dias,
    required this.horasSemanales,
    required this.horasMensuales,
    required this.horasTotales,
    required this.incidenciasSemanales,
    required this.incidenciasMensuales,
    required this.incidenciasTotales,
  });

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<bool> _showLabel;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Inicializamos las páginas una vez para poder usar su longitud
    _pages = [
      _buildSemanal(),
      _buildMensual(),
      _buildTotal(),
    ];

    // Mostrar solo el label de la página actual al principio
    _showLabel = List.generate(_pages.length, (index) => index == _currentPage);

    // Ocultar tras un retardo
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLabel[_currentPage] = false;
      });
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;

      // Mostrar el label de la página actual
      _showLabel = List.generate(_pages.length, (i) => i == index);
    });

    // Ocultar tras 0.5 segundos
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLabel[index] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDarkMode ? Colors.transparent: Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: const Text("F I C H I"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
         elevation: 0,
         flexibleSpace: Container(
    decoration: BoxDecoration(
      color: appBarColor, // o el color que quieras
    ),
  ),
      ),
      body: Stack(
        children: [
          PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_pages.length, (index) {
                final isActive = _currentPage == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Etiqueta animada
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        offset: _showLabel[index] ? Offset.zero : const Offset(0.2, 0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showLabel[index] ? 1.0 : 0.0,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Text(
                              index == 0
                                  ? "Semanal"
                                  : index == 1
                                      ? "Mensual"
                                      : "Total",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      // Indicador
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 8,
                        height: isActive ? 24 : 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTitulo(String titulo) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 60),
        child: Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );

  Widget _buildSemanal() {
    const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return SafeArea(
      child: Center(
        child: Column(
          children: [
            _buildTitulo("Estadísticas Semanales"),
            const Text("Horas trabajadas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            EstadoCircularHoras(
              horasTrabajadas: widget.horasSemanales,
              horasTotales: 40,
            ),
            const SizedBox(height: 20),
            const Text("Días trabajados", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.dias.length, (index) {
                final trabajado = widget.dias[index];
                final letra = diasSemana[index % 7];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: trabajado ? Colors.green : Colors.red,
                    child: Text(
                      letra,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            const Text("Incidencias que has registrado", style: TextStyle(fontSize: 18)),
            EstadoCircularIncidencias(incidencias: widget.incidenciasSemanales),
          ],
        ),
      ),
    );
  }

  Widget _buildMensual() {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            _buildTitulo("Estadísticas Mensuales"),
            const Text("Horas trabajadas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            EstadoCircularHoras(
              horasTrabajadas: widget.horasMensuales, // Ejemplo: semanas * 4
              horasTotales: 160,
            ),
            const SizedBox(height: 40),
            const Text("Incidencias que has registrado", style: TextStyle(fontSize: 18)),
            EstadoCircularIncidencias(incidencias: widget.incidenciasMensuales),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal() {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            _buildTitulo("Estadísticas Totales"),
            const Text("Horas trabajadas totales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            EstadoCircularHoras(
              horasTrabajadas: widget.horasTotales,
              horasTotales: widget.horasTotales,
            ),
            const SizedBox(height: 40),
            const Text("Incidencias totales", style: TextStyle(fontSize: 18)),
            EstadoCircularIncidencias(incidencias: widget.incidenciasTotales),
          ],
        ),
      ),
    );
  }
}