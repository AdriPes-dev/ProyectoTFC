import 'package:fichi/model_classes/empresa.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model_classes/actividad.dart';
import '../services/consultas_firebase.dart';

class PantallaHistorialActividades extends StatefulWidget {
  final Empresa empresa;

  const PantallaHistorialActividades({super.key, required this.empresa});

  @override
  State<PantallaHistorialActividades> createState() => _PantallaHistorialActividadesState();
}

class _PantallaHistorialActividadesState extends State<PantallaHistorialActividades> {
  late Future<List<Actividad>> _historialActividades;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _historialActividades = _cargarHistorial();
  }

  Future<List<Actividad>> _cargarHistorial() async {
    return await _firebaseService.obtenerHistorialActividades(widget.empresa.cif);
  }

  Future<void> _recargarHistorial() async {
    setState(() {
      _historialActividades = _cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Actividades'),
      ),
      body: RefreshIndicator(
        onRefresh: _recargarHistorial,
        child: FutureBuilder<List<Actividad>>(
          future: _historialActividades,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay actividades en el historial'));
            }

            final actividades = snapshot.data!;
            return ListView.builder(
              itemCount: actividades.length,
              itemBuilder: (context, index) {
                final actividad = actividades[index];

                return TweenAnimationBuilder(
  duration: Duration(milliseconds: 400 + index * 50), // animación escalonada
  tween: Tween<double>(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, (1 - value) * 20), // animación de entrada desde abajo
        child: _AnimatedCardWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 0), // sombra en todos los lados
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, size: 40),
                title: Text(actividad.titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(actividad.descripcion),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(actividad.fechaActividad),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedCardWrapper({required this.child});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.97);
  void _onTapUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
