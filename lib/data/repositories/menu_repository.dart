import 'package:sqflite/sqflite.dart';

import '../db/database_provider.dart';
import '../models/menu_item.dart';

class MenuRepository {
  MenuRepository({
    required DatabaseGetter databaseGetter,
  }) : _databaseGetter = databaseGetter;

  final DatabaseGetter _databaseGetter;

  Future<int> insertMenuItem(MenuItem item) async {
    final Database db = await _databaseGetter();
    return db.insert('menu_items', item.toMap());
  }

  Future<void> insertIgnore(MenuItem item) async {
    final Database db = await _databaseGetter();
    await db.insert(
      'menu_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<MenuItem?> getByCode(String itemCode) async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'menu_items',
      where: 'item_code = ? AND is_active = 1',
      whereArgs: <Object>[itemCode],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return MenuItem.fromMap(result.first);
  }

  Future<List<MenuItem>> getAll() async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'menu_items',
      orderBy: 'item_code ASC',
    );
    return result.map(MenuItem.fromMap).toList();
  }

  Future<void> seedDefaultMenu() async {
    const List<MenuItem> items = <MenuItem>[
      MenuItem(itemCode: '1', itemName: '雞排', price: 80),
      MenuItem(itemCode: '2', itemName: '薯條', price: 50),
      MenuItem(itemCode: '3', itemName: '甜不辣', price: 45),
      MenuItem(itemCode: '4', itemName: '米血', price: 35),
      MenuItem(itemCode: '5', itemName: '百頁豆腐', price: 40),
    ];

    for (final MenuItem item in items) {
      await insertIgnore(item);
    }
  }
}
