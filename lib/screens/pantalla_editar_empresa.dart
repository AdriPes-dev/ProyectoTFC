import 'package:fichi/components/bordes_degradados.dart';
import 'package:fichi/components/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:fichi/model_classes/empresa.dart';
import 'package:fichi/services/consultas_firebase.dart';

class PantallaEditarEmpresa extends StatefulWidget {
  final Empresa empresa;

  const PantallaEditarEmpresa({
    super.key,
    required this.empresa,
  });

  @override
  State<PantallaEditarEmpresa> createState() => _PantallaEditarEmpresaState();
}

class _PantallaEditarEmpresaState extends State<PantallaEditarEmpresa> {
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _sectorController;

  bool _cambiosRealizados = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.empresa.nombre);
    _direccionController = TextEditingController(text: widget.empresa.direccion);
    _telefonoController = TextEditingController(text: widget.empresa.telefono);
    _emailController = TextEditingController(text: widget.empresa.email);
    _sectorController = TextEditingController(text: widget.empresa.sector);

    _nombreController.addListener(_verificarCambios);
    _direccionController.addListener(_verificarCambios);
    _telefonoController.addListener(_verificarCambios);
    _emailController.addListener(_verificarCambios);
    _sectorController.addListener(_verificarCambios);
  }

  void _verificarCambios() {
    bool cambios = _nombreController.text != widget.empresa.nombre ||
        _direccionController.text != widget.empresa.direccion ||
        _telefonoController.text != widget.empresa.telefono ||
        _emailController.text != widget.empresa.email ||
        _sectorController.text != widget.empresa.sector;

    if (_cambiosRealizados != cambios) {
      setState(() {
        _cambiosRealizados = cambios;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _sectorController.dispose();
    super.dispose();
  }
void _mostrarDialogoEliminarEmpresa() {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Eliminar Empresa"),
        content: const Text("¿Estás seguro de que deseas eliminar esta empresa?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              setState(() {
                _isLoading = true;
              });

              try {
                await FirebaseService().eliminarEmpresa(widget.empresa.cif);

                if (widget.empresa.jefeDni != null) {
                  final personaActualizada = await FirebaseService().obtenerPersonaPorDni(widget.empresa.jefeDni!);

                  // Verifica que el widget sigue montado antes de navegar
                  if (!mounted) return;

                  Navigator.of(context).pop(personaActualizada);
                } else {
                  if (!mounted) return;

                  CustomSnackbar.mostrar(
                    context,
                    'No se pudo obtener el jefe de la empresa',
                    icono: Icons.error_outline,
                    texto: Colors.red,
                  );
                }
              } catch (e) {
                if (!mounted) return;

               CustomSnackbar.mostrar(
                    context,
                    'Error al eliminar la empresa: $e',
                    icono: Icons.error_outline,
                    texto: Colors.red,
                  );
              } finally {
                if (!mounted) return;

                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Empresa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _mostrarDialogoEliminarEmpresa,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Datos de Empresa", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildReadOnlyField("CIF", widget.empresa.cif),
              _buildTextField("Nombre", _nombreController),
              _buildTextField("Dirección", _direccionController),
              _buildTextField("Teléfono", _telefonoController),
              _buildTextField("Email", _emailController),
              _buildTextField("Sector", _sectorController),
              const SizedBox(height: 30),
              Center(
                child: CupertinoButton(
                  onPressed: (_isLoading || !_cambiosRealizados) ? null : _guardarCambios,
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: (_isLoading || !_cambiosRealizados)
                          ? Border.all(color: Colors.grey, width: 2)
                          : GradientBoxBorder(
                              gradient: AppColors.mainGradient,
                              width: 2,
                            ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ShaderMask(
                            shaderCallback: (bounds) => AppColors.mainGradient.createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: const Text(
                              "Guardar cambios",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

  Future<void> _guardarCambios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Empresa empresaActualizada = Empresa(
        cif: widget.empresa.cif,
        nombre: _nombreController.text,
        direccion: _direccionController.text,
        telefono: _telefonoController.text,
        email: _emailController.text,
        sector: _sectorController.text,
        jefeDni: widget.empresa.jefeDni,
      );

      await FirebaseService().actualizarEmpresa(empresaActualizada);
      CustomSnackbar.mostrar(
          context,
          'Empresa actualizada correctamente',
          icono: Icons.check_circle,
          texto: Colors.green,
        );
      setState(() {
        _cambiosRealizados = false;
      });
    } catch (e) {
      CustomSnackbar.mostrar(
        context,
        'Error al actualizar la empresa: $e',
        icono: Icons.error_outline,
        texto: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
