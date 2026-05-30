import 'package:sqflite/sqflite.dart';

import '../models/sync_event.dart';

typedef DbGetter = Future<Database> Function();

class SyncEventRepository {
  SyncEventRepository({
    required DbGetter databaseGetter,
  }) : _databaseGetter = databaseGetter;

  final DbGetter _databaseGetter;

  Future<Database> get _db async => _databaseGetter();

  Future<void> append(SyncEvent event) async {
    final db = await _db;

    await db.insert(
      'sync_events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<SyncEvent>> listSince({
    required String? minHlcExclusive,
    int limit = 500,
  }) async {
    final db = await _db;

    final String? where = minHlcExclusive != null ? 'hlc > ?' : null;
    final List<Object?>? whereArgs =
        minHlcExclusive != null ? <Object?>[minHlcExclusive] : null;

    final rows = await db.query(
      'sync_events',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'hlc ASC',
      limit: limit,
    );

    return rows.map(SyncEvent.fromMap).toList();
  }
}
