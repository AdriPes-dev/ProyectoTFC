// auth_service.dart
import 'package:fichi/model_classes/empresa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/persona.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;


  // Iniciar sesión y obtener datos del usuario
  Future<Persona?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      // 1. Autenticar con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Obtener datos adicionales de Firestore
      final querySnapshot = await _firestore
          .collection('personas')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw "No se encontraron datos del usuario";
      }

      final userData = querySnapshot.docs.first.data();
      
      // 3. Obtener datos de la empresa si existe
      Empresa? empresa;
      if (userData['empresa'] != null) {
        final empresaData = userData['empresa'] as Map<String, dynamic>;
        empresa = Empresa.map(empresaData);
      }

      // 4. Crear y retornar objeto Persona
      return Persona(
        nombre: userData['nombre'],
        apellidos: userData['apellidos'],
        correo: userData['correo'],
        contrasenya: password, // Guardamos la contraseña en memoria (no en Firestore)
        dni: userData['dni'],
        telefono: userData['telefono'],
        esJefe: userData['esJefe'] ?? false,
        empresa: empresa,
      );
    } catch (e) {
      print("Error en inicio de sesión: $e");
      rethrow; // Relanzamos el error para manejarlo en la UI
    }
  }

  Future<void> crearEmpresa({
  required String cif,
  required String direccion,
  required String telefono,
  required String email,
  required String nombreEmpresa,
  required String sector,
  required Persona personaActual,
}) async {
  try {
    // 1. Crear objeto Empresa
    final empresa = Empresa(
      nombre: nombreEmpresa,
      sector: sector,
      jefe: personaActual, 
      cif: cif, 
      direccion: direccion, 
      telefono: telefono, 
      email: email,
    );

    // 2. Crear la empresa en la colección 'empresas'
    await _firestore.collection('empresas').doc(nombreEmpresa).set(empresa.toMap());

    // 3. Actualizar al usuario para marcarlo como jefe y vincularle la empresa
    await _firestore.collection('personas').doc(personaActual.dni).update({
      'esJefe': true,
      'empresa': empresa.toMap(),
      'empresaCif': empresa.cif,
    });

    print("Empresa creada correctamente y usuario actualizado como jefe.");
  } catch (e) {
    print("Error al crear la empresa: $e");
    rethrow;
  }
}


  // Registrar usuario con email/contraseña y guardar datos adicionales
  Future<User?> registerWithEmailAndPassword(
    String email, 
    String password,
    Persona persona,
  ) async {
    try {
      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Guardar información adicional en Firestore
      await _firestore.collection('personas').doc(persona.dni).set({
        'nombre': persona.nombre,
        'apellidos': persona.apellidos,
        'correo': persona.correo,
        'dni': persona.dni,
        'telefono': persona.telefono,
        'esJefe': persona.esJefe,
        'uid': userCredential.user?.uid, // Guardar UID de Firebase Auth
        'fechaRegistro': FieldValue.serverTimestamp(),
        'empresaCif': persona.empresa?.cif,
      });

      return userCredential.user;
    } catch (e) {
      print("Error en registro: $e");
      return null;
    }
  }
}