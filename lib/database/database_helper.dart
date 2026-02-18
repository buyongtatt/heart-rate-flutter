import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blood_pressure_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('blood_pressure.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE blood_pressure_records ADD COLUMN notes TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blood_pressure_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        heartRate INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<int> insertRecord(BloodPressureRecord record) async {
    final db = await database;
    return await db.insert('blood_pressure_records', record.toMap());
  }

  Future<List<BloodPressureRecord>> getAllRecords() async {
    final db = await database;
    final result = await db.query(
      'blood_pressure_records',
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => BloodPressureRecord.fromMap(map)).toList();
  }

  Future<BloodPressureRecord?> getRecord(int id) async {
    final db = await database;
    final result = await db.query(
      'blood_pressure_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return BloodPressureRecord.fromMap(result.first);
  }

  Future<int> updateRecord(BloodPressureRecord record) async {
    final db = await database;
    return await db.update(
      'blood_pressure_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'blood_pressure_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BloodPressureRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final result = await db.query(
      'blood_pressure_records',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return result.map((map) => BloodPressureRecord.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
