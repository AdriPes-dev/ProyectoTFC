import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/screens/pantallahistorialincidencias.dart';
import 'package:fichi/screens/pantallaverincindencias.dart';
import 'package:fichi/screens/pantallaversolicitudesunion.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/screens/crearempresa.dart';
import 'package:fichi/screens/unirseempresa.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Persona _personaAutenticada;
  Empresa? _empresa;
  Persona? _ceo;
  List<Persona> _empleados = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _personaAutenticada = widget.personaAutenticada;
  _cargarDatosEmpresa();
  }

  Future<void> _cargarDatosEmpresa() async {
    if (widget.personaAutenticada.empresaCif == null || widget.personaAutenticada.empresaCif!.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Obtener datos de la empresa
      final empresa = await FirebaseService().obtenerEmpresaPorCif(widget.personaAutenticada.empresaCif!);
      
      // 2. Obtener CEO si existe
      Persona? ceo;
      if (empresa?.jefeDni != null) {
        ceo = await FirebaseService().obtenerPersonaPorDni(empresa!.jefeDni!);
      }
      
      // 3. Obtener empleados (excluyendo al CEO)
      final empleados = await FirebaseService().obtenerEmpleadosPorEmpresa(empresa!.cif);
      if (ceo != null) {
        empleados.removeWhere((e) => e.dni == ceo!.dni);
      }

      setState(() {
        _empresa = empresa;
        _ceo = ceo;
        _empleados = empleados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_empresa == null) {
      return _buildVistaSinEmpresa();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con información de la empresa
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: _buildEncabezadoEmpresa(),
            ),
            
            // Sección del CEO
            if (_ceo != null) _buildSeccionCEO(),
            
            // Lista de empleados
            _buildListaEmpleados(),
            
            // Acciones para el jefe
            if (_ceo?.dni == widget.personaAutenticada.dni) 
              _buildAccionesJefe(),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezadoEmpresa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _empresa!.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoEmpresa('Sector', _empresa!.sector),
          _buildInfoEmpresa('CIF', _empresa!.cif),
          _buildInfoEmpresa('Teléfono', _empresa!.telefono),
          _buildInfoEmpresa('Email', _empresa!.email),
          _buildInfoEmpresa('Dirección', _empresa!.direccion),
        ],
      ),
    );
  }

  Widget _buildInfoEmpresa(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionCEO() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Fundador/CEO',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTarjetaPersona(_ceo!, esCEO: true),
      ],
    );
  }

  Widget _buildListaEmpleados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              const Text(
                'Equipo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Chip(
                label: Text('${_empleados.length} miembros'),
                backgroundColor: Colors.blue.shade100,
              ),
            ],
          ),
        ),
        if (_empleados.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('No hay otros empleados registrados'),
          )
        else
          ..._empleados.map((e) => _buildTarjetaPersona(e)).toList(),
      ],
    );
  }

  Widget _buildTarjetaPersona(Persona persona, {bool esCEO = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorBox = isDarkMode ? Colors.black : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: colorBox,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: esCEO ? Colors.amber.shade100 : Colors.blue.shade100,
          child: Text(
            persona.nombre[0].toUpperCase(),
            style: TextStyle(
              color: esCEO ? Colors.amber.shade800 : Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(persona.nombreCompleto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(persona.correo),
            if (esCEO)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Fundador/CEO',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            _hacerLlamada(
              persona.telefono,
            );
          },
        ),
      ),
    );
  }

   Future<void> _hacerLlamada(String telefono) async {
  final Uri url = Uri(scheme: 'tel', path: telefono);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print('No se pudo realizar la llamada');
  }
}

  Widget _buildAccionesJefe() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Acciones de administración',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(
                avatar: const Icon(Icons.person_add, size: 18),
                label: const Text('Añadir empleado'),
                onPressed: _anyadirEmpleado,
              ),
              ActionChip(
                avatar: const Icon(Icons.warning, size: 18),
                label: const Text('Incidencias'),
                onPressed: _verIncidencias,
              ),
              ActionChip(
                avatar: const Icon(Icons.settings, size: 18),
                label: const Text('Configuración'),
                onPressed: _configurarEmpresa,
              ),
              ActionChip(
                avatar: const Icon(Icons.history, size: 18),
                label: const Text('Historial Incidencias'),
                onPressed: _verHistorialIncidencias,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _anyadirEmpleado() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitudesEntradaScreen(empresaCif: widget.personaAutenticada.empresaCif!,),
      ),
    );
  }

  void _verIncidencias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaIncidenciasEmpresa(empresa: _empresa!),
      ),
    );
  }

  void _verHistorialIncidencias() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaHistorialIncidenciasEmpresa(empresa: _empresa!),
      ),
    );
  }

  void _configurarEmpresa() {
    // Implementar lógica para configurar empresa
  }

  Widget _buildVistaSinEmpresa() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No estás asociado a ninguna empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_business),
              label: const Text('Crear nueva empresa'),
              onPressed: _crearEmpresa,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('Unirse a empresa existente'),
              onPressed: _unirseAEmpresa,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _crearEmpresa() async {
  final personaActualizada = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CrearEmpresaScreen(persona: _personaAutenticada),
    ),
  );

  

  if (personaActualizada != null && personaActualizada.empresaCif != null) {
    setState(() {
      _personaAutenticada = personaActualizada;
    });
    await _cargarDatosEmpresa();
  }
}

void _unirseAEmpresa() async {
  final resultado = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UnirseAEmpresaScreen(persona: widget.personaAutenticada),
    ),
  );

  if (resultado == true) {
    _recargarDatos();
  }
}

void _recargarDatos() {
  setState(() {
    _isLoading = true;
  });
  _cargarDatosEmpresa();
}
}