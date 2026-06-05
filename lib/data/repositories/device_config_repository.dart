// lib/data/repositories/device_config_repository.dart

import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/device_config.dart';
import '../models/store_config.dart';

class DeviceConfigRepository {
  static const Uuid _uuid = Uuid();

  Future<DeviceConfig?> getDeviceConfig() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'device_config',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return DeviceConfig.fromMap(rows.first);
  }

  Future<StoreConfig?> getStoreConfig() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      'stores',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return StoreConfig.fromMap(rows.first);
  }

  Future<DeviceConfig> ensureDeviceIdentity({
    String? displayName,
  }) async {
    final existing = await getDeviceConfig();
    if (existing != null) {
      return existing;
    }

    final db = await AppDatabase.database;
    final now = DateTime.now().toIso8601String();

    final config = DeviceConfig(
      deviceId: _uuid.v4(),
      storeId: null,
      role: DeviceRole.standalone,
      hostUrl: null,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('device_config', config.toMap());
    return config;
  }

  Future<(StoreConfig, DeviceConfig)> createNewStore({
    String? storeName,
    String? displayName,
    String? hostUrl,
  }) async {
    final db = await AppDatabase.database;
    final now = DateTime.now().toIso8601String();

    final existingDevice = await getDeviceConfig();
    final deviceId = existingDevice?.deviceId ?? _uuid.v4();
    final storeId = _uuid.v4();

    final store = StoreConfig(
      storeId: storeId,
      storeName: storeName,
      createdAt: now,
      updatedAt: now,
    );

    final device = DeviceConfig(
      id: existingDevice?.id,
      deviceId: deviceId,
      storeId: storeId,
      role: DeviceRole.storeHost,
      hostUrl: hostUrl,
      displayName: displayName,
      createdAt: existingDevice?.createdAt ?? now,
      updatedAt: now,
    );

    await db.transaction((txn) async {
      await txn.delete('stores');
      await txn.insert('stores', store.toMap());

      await txn.delete('device_config');
      await txn.insert('device_config', device.toMap());
    });

    return (store, device);
  }

  Future<DeviceConfig> joinExistingStore({
    required String storeId,
    required String hostUrl,
    String? storeName,
    String? displayName,
  }) async {
    final db = await AppDatabase.database;
    final now = DateTime.now().toIso8601String();

    final existingDevice = await getDeviceConfig();
    final deviceId = existingDevice?.deviceId ?? _uuid.v4();

    final device = DeviceConfig(
      id: existingDevice?.id,
      deviceId: deviceId,
      storeId: storeId,
      role: DeviceRole.storePeer,
      hostUrl: hostUrl,
      displayName: displayName,
      createdAt: existingDevice?.createdAt ?? now,
      updatedAt: now,
    );

    final store = StoreConfig(
      storeId: storeId,
      storeName: storeName,
      createdAt: now,
      updatedAt: now,
    );

    await db.transaction((txn) async {
      await txn.delete('stores');
      await txn.insert('stores', store.toMap());

      await txn.delete('device_config');
      await txn.insert('device_config', device.toMap());
    });

    return device;
  }

  Future<void> updateHostUrl(String? hostUrl) async {
    final db = await AppDatabase.database;
    final existing = await getDeviceConfig();
    if (existing == null) return;

    await db.update(
      'device_config',
      {
        'host_url': hostUrl,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [existing.id],
    );
  }
}
