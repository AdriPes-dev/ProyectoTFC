import 'package:fichi/model_classes/fichaje.dart';
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nif TEXT NOT NULL,
      empresaNombre TEXT NOT NULL,
      horaEntrada TEXT NOT NULL,
      horaSalida TEXT
    )
    ''');
  }

  // Insertar un fichaje
  Future<int> insertarFichaje(Fichaje fichaje) async {
    final db = await instance.database;
    return await db.insert('fichajes', fichaje.toMap());
  }

  // Actualizar fichaje (por ejemplo, para registrar la salida)
  Future<int> actualizarFichaje(Fichaje fichaje) async {
    final db = await instance.database;
    return await db.update(
      'fichajes',
      fichaje.toMap(),
      where: 'id = ?',
      whereArgs: [fichaje.id],
    );
  }

  // Obtener todos los fichajes
  Future<List<Fichaje>> obtenerFichajes() async {
    final db = await instance.database;

    final result = await db.query('fichajes');

    return result.map((json) => Fichaje.fromMap(json)).toList();
  }
}
