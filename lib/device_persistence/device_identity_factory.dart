import 'dart:math';

import '../app_role.dart';
import '../sync_mode.dart';
import 'device_record.dart';

class DeviceIdentityFactory {
  const DeviceIdentityFactory();

  DeviceRecord createInitialRecord(AppRole installedRole) {
    final deviceId = _generateDeviceId(installedRole);
    final deviceName = _defaultDeviceName(installedRole);

    switch (installedRole) {
      case AppRole.frontdesk:
        return DeviceRecord(
          deviceId: deviceId,
          deviceName: deviceName,
          installedRole: AppRole.frontdesk,
          allowRoleOverride: false,
          allowedRuntimeRoles: {
            AppRole.frontdesk,
          },
          defaultSyncMode: SyncMode.standalone,
        );
      case AppRole.kitchen:
        return DeviceRecord(
          deviceId: deviceId,
          deviceName: deviceName,
          installedRole: AppRole.kitchen,
          allowRoleOverride: false,
          allowedRuntimeRoles: {
            AppRole.kitchen,
          },
          defaultSyncMode: SyncMode.standalone,
        );
      case AppRole.backoffice:
        return DeviceRecord(
          deviceId: deviceId,
          deviceName: deviceName,
          installedRole: AppRole.backoffice,
          allowRoleOverride: true,
          allowedRuntimeRoles: {
            AppRole.backoffice,
            AppRole.frontdesk,
            AppRole.kitchen,
          },
          defaultSyncMode: SyncMode.viewer,
        );
      case AppRole.combined:
        return DeviceRecord(
          deviceId: deviceId,
          deviceName: deviceName,
          installedRole: AppRole.combined,
          allowRoleOverride: true,
          allowedRuntimeRoles: {
            AppRole.combined,
            AppRole.backoffice,
            AppRole.frontdesk,
            AppRole.kitchen,
          },
          defaultSyncMode: SyncMode.host,
        );
    }
  }

  String _generateDeviceId(AppRole role) {
    final random = Random.secure();
    final suffix = List.generate(
      8,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();

    return '${role.name}-$suffix';
  }

  String _defaultDeviceName(AppRole role) {
    switch (role) {
      case AppRole.frontdesk:
        return 'Frontdesk Terminal';
      case AppRole.kitchen:
        return 'Kitchen Terminal';
      case AppRole.backoffice:
        return 'Backoffice Terminal';
      case AppRole.combined:
        return 'Combined Admin Terminal';
    }
  }
}
