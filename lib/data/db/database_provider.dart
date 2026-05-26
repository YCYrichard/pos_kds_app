import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';

typedef DatabaseGetter = Future<Database> Function();

class DatabaseProvider {
  const DatabaseProvider._();

  static Future<Database> appDatabase() {
    return AppDatabase.database;
  }
}
