import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/persona.dart';
import 'package:fichi/model_classes/empresa.dart';

class UnirseAEmpresaScreen extends StatefulWidget {
  final Persona persona;

  const UnirseAEmpresaScreen({super.key, required this.persona});

  @override
  State<UnirseAEmpresaScreen> createState() => _UnirseAEmpresaScreenState();
}

class _UnirseAEmpresaScreenState extends State<UnirseAEmpresaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Empresa> _todasLasEmpresas = [];
  List<Empresa> _empresasFiltradas = [];


  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
  final search = _searchController.text.toLowerCase();

  setState(() {
    _empresasFiltradas = _todasLasEmpresas.where((empresa) {
      return empresa.nombre.toLowerCase().contains(search) ||
             empresa.cif.toLowerCase().contains(search);
    }).toList();
  });
}

  Future<void> _cargarEmpresas() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('empresas')
        .limit(50) // Puedes ajustar este número
        .get();

    final empresas = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      return Empresa(
        cif: data['cif'] as String? ?? '',
        nombre: data['nombre'] as String? ?? 'Empresa sin nombre',
        direccion: data['direccion'] as String? ?? '',
        telefono: data['telefono'] as String? ?? '',
        email: data['email'] as String? ?? '',
        sector: data['sector'] as String? ?? '',
        jefeDni: data['jefeDni'],
      );
    }).toList();

    setState(() {
      _todasLasEmpresas = empresas;
      _empresasFiltradas = empresas;
    });
  } catch (e) {
    print("Error cargando empresas: $e");
  }
}

  Future<void> _unirseAEmpresa(Empresa empresa) async {
  // Si la persona ya tiene un empresaCif asignado, no se puede unir
  if (widget.persona.empresaCif != null && widget.persona.empresaCif!.isNotEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ya perteneces a una empresa.")),
      );
    }
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('personas')
        .doc(widget.persona.dni)
        .update({
      'empresaCif': empresa.cif,
    });

    // Actualiza el objeto local
    setState(() {
      widget.persona.empresaCif = empresa.cif;
    });

    if (mounted) {
      Navigator.pop(context, true); // Devuelve 'true' si todo fue bien
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al unirse a la empresa: ${e.toString()}")),
      );
    }
  }
}

  void _showConfirmDialog(Empresa empresa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar unión"),
        content: Text(
            "¿Estás seguro de que quieres unirte a ${empresa.nombre} (${empresa.cif})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _unirseAEmpresa(empresa);
            },
            child: const Text("Unirse"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unirse a una Empresa")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar empresa (por CIF o nombre)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
  child: _empresasFiltradas.isEmpty
      ? Center(
          child: Text(
            _searchController.text.isEmpty
                ? "No hay empresas registradas"
                : "No se encontraron resultados",
          ),
        )
      : ListView.builder(
          itemCount: _empresasFiltradas.length,
          itemBuilder: (context, index) {
            final empresa = _empresasFiltradas[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.business, size: 40),
                title: Text(empresa.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CIF: ${empresa.cif}"),
                    Text("Sector: ${empresa.sector}"),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _showConfirmDialog(empresa),
                ),
              ),
            );
          },
        ),
)
        ],
      ),
    );
  }
}
