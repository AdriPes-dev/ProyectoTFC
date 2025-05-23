import 'package:cloud_firestore/cloud_firestore.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${persona.nombre} ha sido expulsado.')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Expulsar Empleados')),
      body: empleados.isEmpty
          ? const Center(child: Text('No hay empleados para expulsar.'))
          : ListView.builder(
              itemCount: empleados.length,
              itemBuilder: (context, index) {
                final persona = empleados[index];
                return Dismissible(
                  key: Key(persona.dni),
                  direction: DismissDirection.horizontal, // ←→ ambos lados
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
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(persona.nombre),
                      subtitle: Text('DNI: ${persona.dni}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}