import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../models/menu_item.dart';
import '../models/sync_event.dart';
import 'sync_event_repository.dart';

typedef DbGetter = Future<Database> Function();

class MenuRepository {
  MenuRepository({
    required DbGetter databaseGetter,
    required String deviceId,
    SyncEventRepository? syncEventRepository,
  })  : _databaseGetter = databaseGetter,
        _deviceId = deviceId,
        _syncEventRepository = syncEventRepository;

  final DbGetter _databaseGetter;
  final String _deviceId;
  final SyncEventRepository? _syncEventRepository;

  Future<Database> get _db async => _databaseGetter();

  Future<int> insertMenuItem(MenuItem item) async {
    final db = await _db;
    return db.insert('menu_items', item.toMap());
  }

  Future<void> insertIgnore(MenuItem item) async {
    final db = await _db;
    await db.insert(
      'menu_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<MenuItem?> getByCode(String itemCode) async {
    final db = await _db;
    final result = await db.query(
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
    final db = await _db;
    final result = await db.query(
      'menu_items',
      orderBy: 'item_code ASC',
    );
    return result.map(MenuItem.fromMap).toList();
  }

  Future<List<MenuItem>> getAllActive() async {
    final db = await _db;
    final result = await db.query(
      'menu_items',
      where: 'is_active = 1',
      orderBy: 'item_code ASC',
    );
    return result.map(MenuItem.fromMap).toList();
  }

  /// 只從 JSON asset seed 菜單，沒有任何硬編碼 fallback。
  Future<void> seedDefaultMenu({required String assetPath}) async {
    final List<MenuItem> items = <MenuItem>[];

    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is List) {
        for (final dynamic raw in decoded) {
          if (raw is! Map<String, dynamic>) {
            continue;
          }
          items.add(_fromJson(raw));
        }
      }
    } catch (_) {
      // 讀不到檔或 JSON 壞掉，就不 seed，後面靠 sync 或手動維護。
      return;
    }

    if (items.isEmpty) {
      return;
    }

    for (final MenuItem item in items) {
      await insertIgnore(item);
      await _emitMenuUpsertEvent(item);
    }
  }

  /// 建立或更新一筆菜單資料（依 itemCode 判斷是否存在）
  Future<void> upsertMenuItem(MenuItem item) async {
    final db = await _db;

    final existing = await db.query(
      'menu_items',
      where: 'item_code = ?',
      whereArgs: <Object>[item.itemCode],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('menu_items', item.toMap());
    } else {
      await db.update(
        'menu_items',
        item.toMap(),
        where: 'item_code = ?',
        whereArgs: <Object>[item.itemCode],
      );
    }

    await _emitMenuUpsertEvent(item);
  }

  Future<void> setMenuItemActive(String itemCode, bool isActive) async {
    final db = await _db;

    await db.update(
      'menu_items',
      <String, Object?>{
        'is_active': isActive ? 1 : 0,
      },
      where: 'item_code = ?',
      whereArgs: <Object>[itemCode],
    );

    // 讀出最新的 item 狀態（for event payload）
    final updatedRows = await db.query(
      'menu_items',
      where: 'item_code = ?',
      whereArgs: <Object>[itemCode],
      limit: 1,
    );
    if (updatedRows.isEmpty) {
      return;
    }
    final updatedItem = MenuItem.fromMap(updatedRows.first);
    await _emitMenuUpsertEvent(updatedItem);
  }

  MenuItem _fromJson(Map<String, dynamic> map) {
    final String code = (map['item_code'] ?? map['itemCode']) as String? ?? '';
    final String name = (map['item_name'] ?? map['itemName']) as String? ?? '';
    final int price = (map['price'] as num?)?.toInt() ?? 0;

    final dynamic activeRaw = map['is_active'] ?? map['isActive'];
    bool isActive;
    if (activeRaw is bool) {
      isActive = activeRaw;
    } else if (activeRaw is num) {
      isActive = activeRaw.toInt() != 0;
    } else {
      isActive = true;
    }

    return MenuItem(
      itemCode: code,
      itemName: name,
      price: price,
      isActive: isActive,
    );
  }

  Future<void> _emitMenuUpsertEvent(MenuItem item) async {
    if (_syncEventRepository == null) {
      return;
    }

    final SyncEvent event = SyncEvent.create(
      deviceId: _deviceId,
      entityType: 'menuItem',
      entityId: item.itemCode,
      action: 'menuUpsert',
      payload: <String, Object?>{
        'itemCode': item.itemCode,
        'itemName': item.itemName,
        'price': item.price,
        'isActive': item.isActive,
      },
    );
    await _syncEventRepository!.append(event);
  }
}
