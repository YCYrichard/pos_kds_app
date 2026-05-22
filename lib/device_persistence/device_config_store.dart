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

  Future<void> save(DeviceRecord record) async {
    final file = await _getConfigFile();
    await file.create(recursive: true);
    await file.writeAsString(
      jsonEncode(record.toMap()),
      flush: true,
    );
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
