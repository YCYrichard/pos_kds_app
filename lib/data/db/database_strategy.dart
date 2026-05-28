import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/data/db/database_provider.dart';
import 'package:pos_kds_app/device_config.dart';
import 'package:pos_kds_app/sync_mode.dart';

class DatabaseResolution {
  const DatabaseResolution({
    required this.databaseGetter,
    required this.strategyName,
    this.notes,
  });

  final DatabaseGetter databaseGetter;
  final String strategyName;
  final String? notes;
}

class DatabaseStrategyResolver {
  const DatabaseStrategyResolver();

  DatabaseResolution resolve({
    required DeviceConfig deviceConfig,
    required AppRole runtimeRole,
    required SyncMode resolvedSyncMode,
    required String? hostDeviceId,
  }) {
    switch (runtimeRole) {
      case AppRole.frontdesk:
        return _resolveFrontdesk(
          deviceConfig: deviceConfig,
          resolvedSyncMode: resolvedSyncMode,
          hostDeviceId: hostDeviceId,
        );
      case AppRole.kitchen:
        return _resolveKitchen(
          deviceConfig: deviceConfig,
          resolvedSyncMode: resolvedSyncMode,
          hostDeviceId: hostDeviceId,
        );
      case AppRole.backoffice:
        return _resolveBackoffice(
          deviceConfig: deviceConfig,
          resolvedSyncMode: resolvedSyncMode,
          hostDeviceId: hostDeviceId,
        );
      case AppRole.combined:
        return _resolveCombined(
          deviceConfig: deviceConfig,
          resolvedSyncMode: resolvedSyncMode,
          hostDeviceId: hostDeviceId,
        );
    }
  }

  DatabaseResolution _resolveFrontdesk({
    required DeviceConfig deviceConfig,
    required SyncMode resolvedSyncMode,
    required String? hostDeviceId,
  }) {
    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-frontdesk',
      notes: 'Frontdesk currently uses the local application database.',
    );
  }

  DatabaseResolution _resolveKitchen({
    required DeviceConfig deviceConfig,
    required SyncMode resolvedSyncMode,
    required String? hostDeviceId,
  }) {
    if (hostDeviceId != null && hostDeviceId.isNotEmpty) {
      return const DatabaseResolution(
        databaseGetter: DatabaseProvider.appDatabase,
        strategyName: 'host-linked-kitchen-local-fallback',
        notes:
            'Kitchen host-linked mode currently falls back to local database.',
      );
    }

    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-kitchen',
      notes: 'Kitchen currently uses the local application database.',
    );
  }

  DatabaseResolution _resolveBackoffice({
    required DeviceConfig deviceConfig,
    required SyncMode resolvedSyncMode,
    required String? hostDeviceId,
  }) {
    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-backoffice',
      notes: 'Backoffice currently uses the local application database.',
    );
  }

  DatabaseResolution _resolveCombined({
    required DeviceConfig deviceConfig,
    required SyncMode resolvedSyncMode,
    required String? hostDeviceId,
  }) {
    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-combined',
      notes: 'Combined mode currently uses the local application database.',
    );
  }
}
