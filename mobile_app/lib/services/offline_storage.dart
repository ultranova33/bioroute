import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineStorageService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'bioroute_telemetry.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_telemetry (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            truck_id TEXT,
            temperature_c REAL,
            humidity_percent REAL,
            ethylene_ppm REAL,
            ammonia_ppm REAL,
            rsl_hours REAL,
            timestamp TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<int> cacheTelemetry(Map<String, dynamic> telemetryData) async {
    final db = await database;
    return await db.insert('cached_telemetry', {
      'truck_id': telemetryData['truck_id'] ?? 'TN-01-BIO-9921',
      'temperature_c': telemetryData['temperature_c'],
      'humidity_percent': telemetryData['humidity_percent'],
      'ethylene_ppm': telemetryData['ethylene_ppm'],
      'ammonia_ppm': telemetryData['ammonia_ppm'],
      'rsl_hours': telemetryData['rsl_hours'],
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0
    });
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedTelemetry() async {
    final db = await database;
    return await db.query('cached_telemetry', where: 'synced = 0');
  }

  static Future<int> markAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'cached_telemetry',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
