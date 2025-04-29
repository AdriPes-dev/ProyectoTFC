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
  late Future<List<Empresa>> _empresasFuture;

  @override
  void initState() {
    super.initState();
    _empresasFuture = _cargarEmpresas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _empresasFuture = _cargarEmpresas(searchTerm: _searchController.text);
    });
  }

  Future<List<Empresa>> _cargarEmpresas({String searchTerm = ''}) async {
  try {
    Query query = FirebaseFirestore.instance.collection('empresas');

    if (searchTerm.isNotEmpty) {
      query = query
          .where('searchKeywords', arrayContains: searchTerm.toLowerCase())
          .limit(20);
    } else {
      query = query.limit(20);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {}; // Conversión segura
      
      return Empresa(
        cif: data['cif'] as String? ?? '', // Valor por defecto si es null
        nombre: data['nombre'] as String? ?? 'Empresa sin nombre',
        direccion: data['direccion'] as String? ?? '',
        telefono: data['telefono'] as String? ?? '',
        email: data['email'] as String? ?? '',
        sector: data['sector'] as String? ?? '',
        jefe: data['jefe'] != null 
            ? Persona.map(data['jefe'] as Map<String, dynamic>)
            : Persona( // Persona por defecto si no hay jefe
                nombre: 'Desconocido',
                apellidos: '',
                correo: '',
                contrasenya: '',
                dni: '',
                telefono: '',
                esJefe: false,
              ),
      );
    }).toList();
  } catch (e) {
    print("Error cargando empresas: $e");
    return [];
  }
}

  Future<void> _unirseAEmpresa(Empresa empresa) async {
    if (widget.persona.empresa != null) {
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
        'empresa': {
          'cif': empresa.cif,
          'nombre': empresa.nombre,
          'direccion': empresa.direccion,
          'telefono': empresa.telefono,
          'email': empresa.email,
          'sector': empresa.sector,
        },
        'empresaCif': empresa.cif, // Clave para búsquedas posteriores
      });

      // Actualizar el objeto local
      widget.persona.empresa = empresa;

      if (mounted) {
        Navigator.pop(context, true);
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
            child: FutureBuilder<List<Empresa>>(
              future: _empresasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final empresas = snapshot.data ?? [];

                if (empresas.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? "No hay empresas registradas"
                          : "No se encontraron resultados",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: empresas.length,
                  itemBuilder: (context, index) {
                    final empresa = empresas[index];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
