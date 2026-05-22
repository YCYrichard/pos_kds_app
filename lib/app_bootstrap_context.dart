import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'device_config.dart';

class AppBootstrapContext {
  const AppBootstrapContext({
    required this.role,
    required this.deviceConfig,
    required this.appInstanceId,
    required this.startedAt,
    required this.menuRepository,
    required this.orderRepository,
  });

  final AppRole role;
  final DeviceConfig deviceConfig;
  final String appInstanceId;
  final DateTime startedAt;
  final MenuRepository menuRepository;
  final OrderRepository orderRepository;

  bool get isSingleRole => role != AppRole.combined;
  bool get canOverrideRole => deviceConfig.allowRoleOverride;
}
