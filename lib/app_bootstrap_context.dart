import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'device_config.dart';
import 'sync_mode.dart';
import 'network/network_session.dart';

class AppBootstrapContext {
  const AppBootstrapContext({
    required this.deviceConfig,
    required this.runtimeRole,
    required this.resolvedSyncMode,
    required this.appInstanceId,
    required this.startedAt,
    required this.menuRepository,
    required this.orderRepository,
    required this.resolutionReason,
    required this.databaseStrategyName,
    required this.networkSession,
    this.databaseStrategyNotes,
    this.hostDeviceId,
    this.takeoverSourceRole,
  });

  final DeviceConfig deviceConfig;
  final AppRole runtimeRole;
  final SyncMode resolvedSyncMode;
  final String appInstanceId;
  final DateTime startedAt;
  final MenuRepository menuRepository;
  final OrderRepository orderRepository;
  final String resolutionReason;
  final String databaseStrategyName;
  final String? databaseStrategyNotes;
  final String? hostDeviceId;
  final AppRole? takeoverSourceRole;
  final NetworkSession networkSession;

  bool get isSingleRole => runtimeRole != AppRole.combined;
  bool get canOverrideRole => deviceConfig.allowRoleOverride;
}
