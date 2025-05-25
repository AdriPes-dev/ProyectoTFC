import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/components/custom_snackbar.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';

class ExpulsarEmpleadoScreen extends StatefulWidget {
  final String empresaCif;

  const ExpulsarEmpleadoScreen({super.key, required this.empresaCif});

  @override
  State<ExpulsarEmpleadoScreen> createState() => _ExpulsarEmpleadoScreenState();
}

class _ExpulsarEmpleadoScreenState extends State<ExpulsarEmpleadoScreen> {
  List<Persona> empleados = [];

  @override
  void initState() {
    super.initState();
    cargarEmpleados();
  }

  Future<void> cargarEmpleados() async {
    final lista = await FirebaseService().obtenerEmpleadosPorEmpresa(widget.empresaCif);
    final empresa = await FirebaseService().obtenerEmpresaPorCif(widget.empresaCif);
    final empleadosSinJefe = lista.where((e) => e.dni != empresa?.jefeDni).toList();

    setState(() {
      empleados = empleadosSinJefe;
    });
  }

  Future<void> expulsarEmpleado(Persona persona) async {
    await FirebaseFirestore.instance.collection('personas').doc(persona.dni).update({
      'empresaCif': null,
    });

    CustomSnackbar.mostrar(
      context,
      '${persona.nombre} ha sido expulsado.',
      icono: Icons.check_circle,
      texto: Colors.green,
    );
    cargarEmpleados();
  }

  Future<bool> mostrarDialogoConfirmacion(Persona persona) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Text('Confirmar expulsión'),
              ],
            ),
            content: Text('¿Estás seguro de que deseas expulsar a ${persona.nombre}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Expulsar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(title: const Text('Expulsar Empleados')),
      body: empleados.isEmpty
          ? const Center(child: Text('No hay empleados para expulsar.'))
          : ListView.builder(
              itemCount: empleados.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                final persona = empleados[index];
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Dismissible(
                            key: Key(persona.dni),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (_) => mostrarDialogoConfirmacion(persona),
                            onDismissed: (_) => expulsarEmpleado(persona),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              elevation: 5,
                              shadowColor: shadowColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                child: ListTile(
                                  title: Text(persona.nombre),
                                  subtitle: Text('DNI: ${persona.dni}'),
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
            ),
    );
  }
}
