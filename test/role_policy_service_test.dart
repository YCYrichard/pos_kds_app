import 'package:flutter_test/flutter_test.dart';
import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/device_config.dart';
import 'package:pos_kds_app/role_policy_service.dart';
import 'package:pos_kds_app/sync_mode.dart';

void main() {
  group('RolePolicyService', () {
    const service = RolePolicyService();

    test('backoffice device can override to kitchen', () {
      const deviceConfig = DeviceConfig(
        deviceId: 'backoffice-device-01',
        deviceName: 'Backoffice Terminal',
        installedRole: AppRole.backoffice,
        allowedRuntimeRoles: {
          AppRole.backoffice,
          AppRole.frontdesk,
          AppRole.kitchen,
        },
        defaultSyncMode: SyncMode.viewer,
        allowRoleOverride: true,
      );

      final result = service.resolve(
        deviceConfig: deviceConfig,
        requestedRole: AppRole.kitchen,
      );

      expect(result.runtimeRole, AppRole.kitchen);
      expect(result.takeoverSourceRole, AppRole.backoffice);
      expect(result.reason, 'Requested role allowed by device policy.');
      expect(result.resolvedSyncMode, SyncMode.viewer);
    });

    test('kitchen device cannot override to frontdesk', () {
      const deviceConfig = DeviceConfig(
        deviceId: 'kitchen-device-01',
        deviceName: 'Kitchen Terminal',
        installedRole: AppRole.kitchen,
        allowedRuntimeRoles: {
          AppRole.kitchen,
        },
        defaultSyncMode: SyncMode.standalone,
        allowRoleOverride: false,
      );

      final result = service.resolve(
        deviceConfig: deviceConfig,
        requestedRole: AppRole.frontdesk,
      );

      expect(result.runtimeRole, AppRole.kitchen);
      expect(result.takeoverSourceRole, isNull);
      expect(
        result.reason,
        'Requested role rejected by device policy. Falling back to installed role.',
      );
      expect(result.resolvedSyncMode, SyncMode.standalone);
    });

    test('combined device becomes client when hostDeviceId is provided', () {
      const deviceConfig = DeviceConfig(
        deviceId: 'combined-device-01',
        deviceName: 'Combined Admin Terminal',
        installedRole: AppRole.combined,
        allowedRuntimeRoles: {
          AppRole.combined,
          AppRole.backoffice,
          AppRole.frontdesk,
          AppRole.kitchen,
        },
        defaultSyncMode: SyncMode.host,
        allowRoleOverride: true,
      );

      final result = service.resolve(
        deviceConfig: deviceConfig,
        requestedRole: AppRole.kitchen,
        hostDeviceId: 'frontdesk-host-01',
      );

      expect(result.runtimeRole, AppRole.kitchen);
      expect(result.hostDeviceId, 'frontdesk-host-01');
      expect(result.resolvedSyncMode, SyncMode.client);
    });
  });
}
