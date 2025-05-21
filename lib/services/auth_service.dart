import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fichi/model_classes/persona.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;


  // Iniciar sesión y obtener datos del usuario
  Future<Persona?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ); 

    userCredential.toString();

    final querySnapshot = await _firestore
        .collection('personas')
        .where('correo', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw "No se encontraron datos del usuario";
    }

    final userData = querySnapshot.docs.first.data();

    return Persona(
      nombre: userData['nombre'],
      apellidos: userData['apellidos'],
      correo: userData['correo'],
      dni: userData['dni'],
      telefono: userData['telefono'],
      esJefe: userData['esJefe'] ?? false,
      empresaCif: userData['empresaCif'],
    );
  } catch (e) {
    print("Error en inicio de sesión: $e");
    rethrow;
  }
}

Future<void> crearEmpresa({
  required String cif,
  required String nombreEmpresa,
  required String direccion,
  required String telefono,
  required String email,
  required String sector,
  required String jefeDni,
  required Persona personaActual,
}) async {
  try {
    // Guardar la empresa
    await FirebaseFirestore.instance.collection('empresas').doc(cif).set({
      'cif': cif,
      'nombre': nombreEmpresa,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sector': sector,
      'jefeDni': jefeDni,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });

    // Asociar a la persona solo con el CIF
    await FirebaseFirestore.instance
        .collection('personas')
        .doc(personaActual.dni)
        .update({
      'empresaCif': cif,
      'esJefe': true,
    });
  } catch (e) {
    print("Error creando empresa: $e");
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
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar datos en Firestore
      await _firestore.collection('personas').doc(persona.dni).set({
        'nombre': persona.nombre,
        'apellidos': persona.apellidos,
        'correo': persona.correo,
        'dni': persona.dni,
        'telefono': persona.telefono,
        'esJefe': persona.esJefe,
        'uid': userCredential.user?.uid,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'empresaCif': persona.empresaCif ?? '', // Por si es null
      });

      return userCredential.user;
    } catch (e) {
      print("Error registrando usuario: $e");
      rethrow;
    }
  }

  

}