import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_role.dart';
import 'store_bootstrap_record.dart';

class StoreBootstrapStore {
  Future<StoreBootstrapRecord> loadOrCreate({
    required String deviceId,
    required AppRole installedRole,
  }) async {
    final file = await _getConfigFile();

    if (await file.exists()) {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return StoreBootstrapRecord.fromMap(decoded);
    }

    final record = StoreBootstrapRecord.initialFromDevice(
      deviceId: deviceId,
      installedRole: installedRole,
    );
    await save(record);
    return record;
  }

  Future<StoreBootstrapRecord?> loadExisting() async {
    final file = await _getConfigFile();

    if (!await file.exists()) {
      return null;
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StoreBootstrapRecord.fromMap(decoded);
  }

  Future<void> save(StoreBootstrapRecord record) async {
    final file = await _getConfigFile();
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode(record.toMap()),
      flush: true,
    );
  }

  Future<StoreBootstrapRecord> configureAsNewStore({
    required String deviceId,
    required AppRole installedRole,
    required String storeId,
    String? storeName,
    String? hostUrl,
  }) async {
    final record = StoreBootstrapRecord(
      deviceId: deviceId,
      installedRole: installedRole,
      storeId: storeId.trim(),
      storeName: _normalizeNullable(storeName),
      hostUrl: _normalizeNullable(hostUrl),
      hostDeviceId: deviceId,
      joinedAt: DateTime.now().toIso8601String(),
    );

    await save(record);
    return record;
  }

  Future<StoreBootstrapRecord> configureAsJoinedStore({
    required String deviceId,
    required AppRole installedRole,
    required String storeId,
    String? storeName,
    String? hostUrl,
    String? hostDeviceId,
  }) async {
    final record = StoreBootstrapRecord(
      deviceId: deviceId,
      installedRole: installedRole,
      storeId: storeId.trim(),
      storeName: _normalizeNullable(storeName),
      hostUrl: _normalizeNullable(hostUrl),
      hostDeviceId: _normalizeNullable(hostDeviceId),
      joinedAt: DateTime.now().toIso8601String(),
    );

    await save(record);
    return record;
  }

  Future<void> clear() async {
    final file = await _getConfigFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> exists() async {
    final file = await _getConfigFile();
    return file.exists();
  }

  Future<String> getConfigFilePath() async {
    final file = await _getConfigFile();
    return file.path;
  }

  Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(
      directory.path,
      'pos_kds_app',
      'store_bootstrap.json',
    );
    return File(path);
  }

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
