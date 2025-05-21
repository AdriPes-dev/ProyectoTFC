import 'package:fichi/components/bordesdegradados.dart';
import 'package:fichi/services/consultas_firebase.dart';
import 'package:fichi/theme/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fichi/model_classes/persona.dart';

class PantallaPerfil extends StatefulWidget {
  final Persona persona;
  final void Function(Persona) onPersonaActualizada;

  const PantallaPerfil({super.key, required this.persona, required this.onPersonaActualizada});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late Persona _personaEditable;


bool _cambiosRealizados = false;
  bool _isLoading = false;


  @override
void initState() {
  super.initState();

  _nombreController = TextEditingController(text: widget.persona.nombre);
  _apellidosController = TextEditingController(text: widget.persona.apellidos);
  _telefonoController = TextEditingController(text: widget.persona.telefono);

  _nombreController.addListener(_verificarCambios);
  _apellidosController.addListener(_verificarCambios);
  _telefonoController.addListener(_verificarCambios);

  _personaEditable = widget.persona;
}

@override
void dispose() {
  _nombreController.dispose();
  _apellidosController.dispose();
  _telefonoController.dispose();
  super.dispose();
}

void _verificarCambios() {
  bool cambios = _nombreController.text != widget.persona.nombre ||
                 _apellidosController.text != widget.persona.apellidos ||
                 _telefonoController.text != widget.persona.telefono;

  if (_cambiosRealizados != cambios) {
    setState(() {
      _cambiosRealizados = cambios;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final Color _colorLetra = Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Encabezado con la foto y nombre
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: AppColors.primaryBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    CircleAvatar(
      backgroundColor: AppColors.gradientPurple,
      radius: 50,
      child: Text(
        widget.persona.nombre[0].toUpperCase(),
        style: TextStyle(
          fontSize: 40,
          color: _colorLetra,
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Text(
        '${_personaEditable.nombre} ${_personaEditable.apellidos}',
        overflow: TextOverflow.ellipsis, // Corta con "..."
        softWrap: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: _colorLetra
        ),
      ),
    ),
  ],
),
              ),
            ),
          ),

          // Información de la persona
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              "Perfil de ${_personaEditable.nombre}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTextFieldN("Correo", _personaEditable.correo),
          _buildTextFieldN("DNI", _personaEditable.dni),
          _buildTextField("Nombre", _nombreController),
          _buildTextField("Apellidos", _apellidosController),
          _buildTextField("Teléfono", _telefonoController),
          SizedBox(height: 20),
          Center(
  child: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: (_isLoading || !_cambiosRealizados) ? null : _actualizarDatosUsuario,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: (_isLoading || !_cambiosRealizados)
            ? Border.all(color: Colors.grey, width: 2)
            : GradientBoxBorder(
                gradient: AppColors.mainGradient,
                width: 2,
              ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.blue)
          : (_isLoading || !_cambiosRealizados)
              ? Text(
                  "Guardar cambios",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : ShaderMask(
                  shaderCallback: (bounds) => AppColors.mainGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    "Guardar cambios",
                    style: TextStyle(
                      color: Colors.white, // Este color no se usa por ShaderMask
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
    ),
    
  ),
),

              SizedBox(height: 30),
              const SizedBox(height: 80),
        ],
      ),
    );
  }

 Widget _buildTextField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
    ),
  );
}

  Widget _buildTextFieldN(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        enabled: false, // Hace que el campo sea solo lectura
        controller: TextEditingController(text: value), // Muestra el valor de la persona
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  void _actualizarDatosUsuario() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Crear una nueva Persona con los datos modificados
    Persona personaActualizada = Persona(
      dni: widget.persona.dni,
      nombre: _nombreController.text,
      apellidos: _apellidosController.text,
      correo: widget.persona.correo,
      telefono: _telefonoController.text,
      empresaCif: widget.persona.empresaCif,
      esJefe: widget.persona.esJefe,
    );

    // Actualizar en Firebase
    await FirebaseService().actualizarPersona(personaActualizada);

    // Obtener la nueva versión desde Firebase
    Persona? actualizada = await FirebaseService().obtenerPersonaPorDni(widget.persona.dni);

    if (actualizada != null) {
      setState(() {
        _personaEditable = actualizada;
        _nombreController.text = actualizada.nombre;
        _apellidosController.text = actualizada.apellidos;
        _telefonoController.text = actualizada.telefono;
        _cambiosRealizados = false;
      });
        widget.onPersonaActualizada(actualizada);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos actualizados correctamente.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al actualizar los datos: $e')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
}
