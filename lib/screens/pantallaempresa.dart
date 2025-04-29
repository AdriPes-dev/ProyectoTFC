import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/crearempresa.dart';
import 'package:fichi/screens/unirseempresa.dart';

class PantallaEmpresa extends StatefulWidget {
  final Persona personaAutenticada;

  const PantallaEmpresa({
    super.key,
    required this.personaAutenticada,
  });

  @override
  State<PantallaEmpresa> createState() => _PantallaEmpresaState();
}

class _PantallaEmpresaState extends State<PantallaEmpresa> {
  late Future<List<Persona>> _empleadosFuture;

  @override
  void initState() {
    super.initState();
    _empleadosFuture = _cargarEmpleados();
  }

  Future<List<Persona>> _cargarEmpleados() async {
  if (widget.personaAutenticada.empresa == null) return [];

  try {
    final empresa = widget.personaAutenticada.empresa!;

    // Consulta solo los documentos que coincidan con el campo plano empresaCif
    final snapshot = await FirebaseFirestore.instance
        .collection('personas')
        .where('empresaCif', isEqualTo: empresa.cif)
        .get();

    // Mapea los documentos a objetos Persona
    return snapshot.docs
        .map((doc) => Persona.map(doc.data()))
        .toList();

  } catch (e) {
    print("Error cargando empleados: $e");
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    if (widget.personaAutenticada.empresa == null) {
      return _buildVistaSinEmpresa();
    }

    final empresa = widget.personaAutenticada.empresa!;
    final esJefe = empresa.jefe.dni == widget.personaAutenticada.dni;

    return FutureBuilder<List<Persona>>(
      future: _empleadosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final empleados = snapshot.data ?? [];
        final empleadosSinCEO = empleados.where((e) => e.dni != empresa.jefe.dni).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Encabezado con información de la empresa
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresa.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoEmpresa("Sector", empresa.sector),
                      _buildInfoEmpresa("CIF", empresa.cif),
                      _buildInfoEmpresa("Teléfono", empresa.telefono),
                      _buildInfoEmpresa("Email", empresa.email),
                      _buildInfoEmpresa("Dirección", empresa.direccion),
                    ],
                  ),
                ),
              ),

              // Sección del CEO
              
              if (empresa.jefe != null) ...[
  const Padding(
    padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
    child: Text(
      "Fundador/CEO",
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  ),

] else ...[
  const Padding(
    padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
    child: Text(
      "⚠️ CEO no asignado",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    ),
  ),
  const SizedBox(height: 10),
  Text(
    "Esta empresa no tiene un CEO asignado",
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey[600],
    ),
  ),
],
              _buildMiembroEmpresa(empresa.jefe, true),

              // Lista de empleados (datos reales de Firebase)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Row(
                  children: [
                    const Text(
                      "Equipo",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(
                        "${empleadosSinCEO.length} miembros",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              if (empleadosSinCEO.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text("No hay otros empleados registrados"),
                )
              else
                ...empleadosSinCEO.map((empleado) => _buildMiembroEmpresa(empleado, false)).toList(),

              // Botones de acción para el jefe
              if (esJefe) _buildAccionesJefe(empresa),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccionesJefe(Empresa empresa) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            "Acciones de administración",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(
                avatar: const Icon(Icons.person_add, size: 18),
                label: const Text("Añadir empleado"),
                onPressed: () {
                  // Acción para añadir empleado
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.bar_chart, size: 18),
                label: const Text("Estadísticas"),
                onPressed: () {
                  // Acción para ver estadísticas
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.settings, size: 18),
                label: const Text("Configuración"),
                onPressed: () {
                  // Acción para configuración
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVistaSinEmpresa() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "No estás asociado a ninguna empresa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_business),
                label: const Text("Crear nueva empresa"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _crearEmpresa,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text("Unirse a empresa existente"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _unirseAEmpresa,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoEmpresa(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiembroEmpresa(Persona? persona, bool esCeo) {
  // Manejo seguro de persona nula
  if (persona == null) {
    return const ListTile(
      leading: CircleAvatar(child: Icon(Icons.error)),
      title: Text('Información no disponible'),
    );
  }

  // Obtener inicial para el avatar
  final nombre = persona.nombre?.trim() ?? 'NN';
  final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  final correo = persona.correo ?? 'Sin correo';
  final telefono = persona.telefono ?? '';

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: esCeo ? Colors.amber.shade100 : Colors.grey.shade200,
              child: Text(
                inicial,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: esCeo ? Colors.amber.shade800 : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correo,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (esCeo)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            "Fundador/CEO",
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (telefono.isNotEmpty)
              IconButton(
                icon: Icon(Icons.phone, color: Colors.blue.shade600),
                onPressed: () {
                  // Acción para llamar al empleado
                },
              ),
          ],
        ),
      ),
    ),
  );
}

  void _crearEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }

  void _unirseAEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnirseAEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }
  /*void _crearEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }

  void _unirseAEmpresa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnirseAEmpresaScreen(persona: widget.personaAutenticada),
      ),
    );
  }*/
}