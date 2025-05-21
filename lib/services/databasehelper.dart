import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fichi/model_classes/fichaje.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fichajes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fichajes (
        id TEXT PRIMARY KEY,
        dniEmpleado TEXT NOT NULL,
        cifEmpresa TEXT NOT NULL,
        entrada TEXT NOT NULL,
        salida TEXT NOT NULL,
        duracion INTEGER NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertarFichaje(Fichaje fichaje) async {
    final db = await instance.database;
    return await db.insert('fichajes', fichaje.toMap());
  }

  Future<int> actualizarFichaje(Fichaje fichaje) async {
    final db = await instance.database;
    return await db.update(
      'fichajes',
      fichaje.toMap(),
      where: 'id = ?',
      whereArgs: [fichaje.id],
    );
  }

  Future<List<Fichaje>> obtenerFichajes() async {
    final db = await instance.database;
    final result = await db.query('fichajes');
    return result.map((json) => Fichaje.fromMap(json)).toList();
  }

  Future<void> guardarFichajeEnFirestore(Fichaje fichaje) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('fichajes')
          .doc(fichaje.id);

      await docRef.set(fichaje.toJson());

      print('Fichaje guardado en Firestore correctamente.');
    } catch (e) {
      print('Error al guardar fichaje en Firestore: $e');
      rethrow;
    }
  }

  Future<void> guardarFichaje(Fichaje fichaje) async {
  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult != ConnectivityResult.none) {
    try {
      await guardarFichajeEnFirestore(fichaje);

      // Crear nueva instancia con sincronizado = true
      final fichajeSincronizado = Fichaje(
        id: fichaje.id,
        dniEmpleado: fichaje.dniEmpleado,
        cifEmpresa: fichaje.cifEmpresa,
        entrada: fichaje.entrada,
        salida: fichaje.salida,
        duracion: fichaje.duracion,
        sincronizado: true,
      );

      await insertarFichaje(fichajeSincronizado);

      print("Fichaje guardado en Firestore.");
    } catch (e) {
      print("Error al guardar en Firestore. Guardando en local.");
      await insertarFichaje(fichaje); // Se guarda con sincronizado: false
    }
  } else {
    print("Sin conexión. Guardando fichaje en local.");
    await insertarFichaje(fichaje); // Se guarda con sincronizado: false
  }
}

  Future<void> guardarFichajeTemporalEnPrefs(Fichaje fichaje) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fichaje_temporal', fichaje.toJsonString());
  }

  Future<Fichaje?> recuperarFichajeTemporalDesdePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fichaje_temporal');
    if (jsonString != null) {
      return Fichaje.fromJsonString(jsonString);
    }
    return null;
  }

  Future<void> eliminarFichajeTemporal() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('fichaje_temporal');
  }

  Future<List<Fichaje>> obtenerFichajesPendientes() async {
    final db = await instance.database;
    final result = await db.query('fichajes', where: 'sincronizado = ?', whereArgs: [0]);
    return result.map((json) => Fichaje.fromMap(json)).toList();
  }

  Future<void> marcarFichajeComoSincronizado(String id) async {
    final db = await instance.database;
    await db.update('fichajes', {'sincronizado': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> sincronizarFichajesPendientes() async {
    final List<Fichaje> pendientes = await obtenerFichajesPendientes();
    for (var fichaje in pendientes) {
      try {
        await guardarFichajeEnFirestore(fichaje);
        await marcarFichajeComoSincronizado(fichaje.id);
      } catch (e) {
        print("Error sincronizando fichaje ${fichaje.id}: $e");
      }
    }
  }
}
