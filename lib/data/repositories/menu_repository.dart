import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/menu_item.dart';

class MenuRepository {
  Future<int> insertMenuItem(MenuItem item) async {
    final db = await AppDatabase.database;
    return db.insert('menu_items', item.toMap());
  }

  Future<void> insertIgnore(MenuItem item) async {
    final db = await AppDatabase.database;
    await db.insert(
      'menu_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<MenuItem?> getByCode(String itemCode) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'menu_items',
      where: 'item_code = ? AND is_active = 1',
      whereArgs: [itemCode],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return MenuItem.fromMap(result.first);
  }

  Future<List<MenuItem>> getAll() async {
    final db = await AppDatabase.database;
    final result = await db.query('menu_items', orderBy: 'item_code ASC');
    return result.map(MenuItem.fromMap).toList();
  }

  Future<void> seedDefaultMenu() async {
    final items = [
      const MenuItem(itemCode: '1', itemName: '雞排', price: 80),
      const MenuItem(itemCode: '2', itemName: '薯條', price: 50),
      const MenuItem(itemCode: '3', itemName: '甜不辣', price: 45),
      const MenuItem(itemCode: '4', itemName: '米血', price: 35),
      const MenuItem(itemCode: '5', itemName: '百頁豆腐', price: 40),
    ];

    for (final item in items) {
      await insertIgnore(item);
    }
  }
}
