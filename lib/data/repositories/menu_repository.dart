import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
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

  Future<void> seedDefaultMenu({
    required String assetPath,
  }) async {
    final String jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> rawList = jsonDecode(jsonString) as List<dynamic>;

    final List<MenuItem> items = rawList
        .map(
            (dynamic entry) => _menuItemFromJson(entry as Map<String, dynamic>))
        .toList();

    for (final MenuItem item in items) {
      await insertIgnore(item);
    }
  }

  MenuItem _menuItemFromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemCode: json['itemCode'] as String,
      itemName: json['itemName'] as String,
      price: (json['price'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
