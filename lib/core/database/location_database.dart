import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/requests/socket_driver_live_location_request.dart';

/// Persistent location database matching Kotlin's Room DB (table_location).
///
/// Stores driver locations locally so they survive app kills and network drops.
/// Locations are flushed to server via socket and deleted on server ACK.
class LocationDatabase {
  static const String _dbName = 'driver_location.db';
  static const String _tableName = 'table_location';
  static const int _dbVersion = 1;

  static LocationDatabase? _instance;
  static LocationDatabase get instance => _instance ??= LocationDatabase._();

  LocationDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            time INTEGER,
            speed REAL,
            bearing REAL
          )
        ''');
      },
    );
  }

  /// Insert a single location into the database.
  Future<void> insertLocation(SocketLocation location) async {
    final db = await database;
    await db.insert(_tableName, {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'time': location.time,
      'speed': location.speed,
      'bearing': location.bearing,
    });
  }

  /// Get all queued locations ordered by id ascending.
  Future<List<SocketLocation>> getAllLocations() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'id ASC');
    return rows
        .map((row) => SocketLocation(
              latitude: row['latitude'] as double?,
              longitude: row['longitude'] as double?,
              time: row['time'] as int?,
              speed: row['speed'] as double?,
              bearing: row['bearing'] as double?,
            ))
        .toList();
  }

  /// Delete all locations where time <= given time (server ACK).
  Future<void> deleteLocationsUpTo(int time) async {
    final db = await database;
    final count = await db.delete(
      _tableName,
      where: 'time <= ?',
      whereArgs: [time],
    );
    debugPrint('LocationDatabase: deleted $count locations up to time=$time');
  }

  /// Delete all locations (used on offline/reset).
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_tableName);
    debugPrint('LocationDatabase: deleted all locations');
  }
}
