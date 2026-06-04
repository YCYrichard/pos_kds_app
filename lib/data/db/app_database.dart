import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'schema.dart';

class AppDatabase {
  static Database? _database;
  static const String _dbName = 'pos_kds_app.db';

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await db.execute(createMenuItemsTable);
        await db.execute(createOrdersTable);
        await db.execute(createOrderItemsTable);
        await db.execute(createSyncEventsTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE orders ADD COLUMN released_at TEXT',
          );
        }
        if (oldVersion < 3) {
          await db.execute(createSyncEventsTable);
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE order_items ADD COLUMN unit_price INTEGER',
          );
        }
      },
    );
  }

  static Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
  }
}
