import 'dart:async';

import 'package:sqflite/sqflite.dart';

class SensorReading {
  final String id;
  final String deviceId;
  final String sensorId;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final DateTime? syncedAt;

  const SensorReading({
    required this.id,
    required this.deviceId,
    required this.sensorId,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() => {
        _columnId: id,
        _columnDeviceId: deviceId,
        _columnSensorId: sensorId,
        _columnValue: value,
        _columnUnit: unit,
        _columnRecordedAt: recordedAt.toIso8601String(),
        _columnSyncedAt: syncedAt?.toIso8601String(),
      };
}

const String _tableName = 'sensor_readings';
const String _columnId = 'id';
const String _columnDeviceId = 'device_id';
const String _columnSensorId = 'sensor_id';
const String _columnValue = 'value';
const String _columnUnit = 'unit';
const String _columnRecordedAt = 'recorded_at';
const String _columnSyncedAt = 'synced_at';

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

abstract class ISensorReadingCache {
  Future<void> saveReadings(List<SensorReading> readings);
  Future<List<SensorReading>> getLatestReadings(String deviceId);
  Future<SensorReading?> getLastKnownReading(String sensorId);
  Future<void> clearOlderThan(Duration age);
}

class SensorReadingCache implements ISensorReadingCache {
  SensorReadingCache(this._db);

  final Database _db;

  @override
  Future<void> saveReadings(List<SensorReading> readings) async {
    final batch = _db.batch();
    for (final reading in readings) {
      batch.insert(
        _tableName,
        reading.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<SensorReading>> getLatestReadings(String deviceId) async {
    final maps = await _db.query(
      _tableName,
      where: '$_columnDeviceId = ?',
      whereArgs: [deviceId],
      orderBy: '$_columnRecordedAt DESC',
      limit: 100,
    );
    return maps.map(_fromMap).toList();
  }

  @override
  Future<SensorReading?> getLastKnownReading(String sensorId) async {
    final maps = await _db.query(
      _tableName,
      where: '$_columnSensorId = ?',
      whereArgs: [sensorId],
      orderBy: '$_columnRecordedAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  @override
  Future<void> clearOlderThan(Duration age) async {
    final cutoff = DateTime.now().subtract(age);
    await _db.delete(
      _tableName,
      where: '$_columnRecordedAt < ?',
      whereArgs: [cutoff.toIso8601String()],
    );
  }

  SensorReading _fromMap(Map<String, dynamic> map) => SensorReading(
        id: map[_columnId] as String,
        deviceId: map[_columnDeviceId] as String,
        sensorId: map[_columnSensorId] as String,
        value: (map[_columnValue] as num).toDouble(),
        unit: map[_columnUnit] as String,
        recordedAt: DateTime.parse(map[_columnRecordedAt] as String),
        syncedAt: map[_columnSyncedAt] != null
            ? DateTime.parse(map[_columnSyncedAt] as String)
            : null,
      );
}
