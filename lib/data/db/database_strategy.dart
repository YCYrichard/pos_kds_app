import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/data/db/data_access_profile.dart';
import 'package:pos_kds_app/data/db/database_provider.dart';
import 'package:pos_kds_app/device_config.dart';
import 'package:pos_kds_app/sync_mode.dart';

class DatabaseResolution {
  const DatabaseResolution({
    required this.databaseGetter,
    required this.strategyName,
    required this.accessProfile,
    this.notes,
  });

  final DatabaseGetter databaseGetter;
  final String strategyName;
  final DataAccessProfile accessProfile;
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
      accessProfile: DataAccessProfile(
        canReadMenu: true,
        canWriteMenu: false,
        canReadOrders: true,
        canWriteOrders: true,
        canCompleteKitchenItems: false,
        canViewBackofficeSummary: false,
      ),
      notes: 'Frontdesk uses local database and can create orders.',
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
        accessProfile: DataAccessProfile(
          canReadMenu: true,
          canWriteMenu: false,
          canReadOrders: true,
          canWriteOrders: false,
          canCompleteKitchenItems: true,
          canViewBackofficeSummary: false,
        ),
        notes:
            'Kitchen host-linked mode currently falls back to local database.',
      );
    }

    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-kitchen',
      accessProfile: DataAccessProfile(
        canReadMenu: true,
        canWriteMenu: false,
        canReadOrders: true,
        canWriteOrders: false,
        canCompleteKitchenItems: true,
        canViewBackofficeSummary: false,
      ),
      notes: 'Kitchen uses local database and can complete kitchen items.',
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
      accessProfile: DataAccessProfile(
        canReadMenu: true,
        canWriteMenu: true,
        canReadOrders: true,
        canWriteOrders: false,
        canCompleteKitchenItems: false,
        canViewBackofficeSummary: true,
      ),
      notes: 'Backoffice uses local database and can manage menu data.',
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
      accessProfile: DataAccessProfile(
        canReadMenu: true,
        canWriteMenu: true,
        canReadOrders: true,
        canWriteOrders: true,
        canCompleteKitchenItems: true,
        canViewBackofficeSummary: true,
      ),
      notes: 'Combined mode has full local access.',
    );
  }
}
