import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_role.dart';
import 'device_identity_factory.dart';
import 'device_record.dart';

class DeviceConfigStore {
  DeviceConfigStore({
    DeviceIdentityFactory? identityFactory,
  }) : _identityFactory = identityFactory ?? const DeviceIdentityFactory();

  final DeviceIdentityFactory _identityFactory;

  Future<DeviceRecord> loadOrCreate(AppRole installedRole) async {
    final file = await _getConfigFile();

    if (await file.exists()) {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return DeviceRecord.fromMap(decoded);
    }

    final record = _identityFactory.createInitialRecord(installedRole);
    await save(record);
    return record;
  }

  Future<DeviceRecord?> loadExisting() async {
    final file = await _getConfigFile();

    if (!await file.exists()) {
      return null;
    }

    final raw = await file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return DeviceRecord.fromMap(decoded);
  }

  Future<void> save(DeviceRecord record) async {
    final file = await _getConfigFile();
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode(record.toMap()),
      flush: true,
    );
  }

  Future<DeviceRecord> updateIdentityFields({
    required String deviceName,
    required String? hostDeviceId,
  }) async {
    final existing = await loadExisting();
    if (existing == null) {
      throw StateError('No existing device config found.');
    }

    final normalizedHost = hostDeviceId?.trim() ?? '';
    final updated = existing.copyWith(
      deviceName: deviceName.trim(),
      hostDeviceId: normalizedHost,
      clearHostDeviceId: normalizedHost.isEmpty,
    );

    await save(updated);
    return updated;
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
      'device_config.json',
    );
    return File(path);
  }
}
