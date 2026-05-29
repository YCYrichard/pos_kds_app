import '../../app_role.dart';
import '../../device_config.dart';
import '../../sync_mode.dart';
import 'database_provider.dart';

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
    return const DatabaseResolution(
      databaseGetter: DatabaseProvider.appDatabase,
      strategyName: 'local-app-database',
      notes:
          'Current bootstrap separation completed with local database fallback.',
    );
  }
}
