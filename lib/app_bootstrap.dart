import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'device_config.dart';

Future<void> bootstrapApp(AppRole role) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceConfig = _buildDeviceConfig(role);
  final context = await _createBootstrapContext(
    role: role,
    deviceConfig: deviceConfig,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DeviceConfig>.value(value: deviceConfig),
        Provider<AppBootstrapContext>.value(value: context),
        Provider<MenuRepository>.value(value: context.menuRepository),
        Provider<OrderRepository>.value(value: context.orderRepository),
      ],
      child: PosKdsApp(role: context.role),
    ),
  );
}

DeviceConfig _buildDeviceConfig(AppRole role) {
  switch (role) {
    case AppRole.frontdesk:
      return const DeviceConfig(
        deviceName: 'frontdesk-device',
        installedRole: AppRole.frontdesk,
        allowRoleOverride: false,
      );
    case AppRole.kitchen:
      return const DeviceConfig(
        deviceName: 'kitchen-device',
        installedRole: AppRole.kitchen,
        allowRoleOverride: false,
      );
    case AppRole.backoffice:
      return const DeviceConfig(
        deviceName: 'backoffice-device',
        installedRole: AppRole.backoffice,
        allowRoleOverride: true,
      );
    case AppRole.combined:
      return const DeviceConfig(
        deviceName: 'combined-device',
        installedRole: AppRole.combined,
        allowRoleOverride: true,
      );
  }
}

Future<AppBootstrapContext> _createBootstrapContext({
  required AppRole role,
  required DeviceConfig deviceConfig,
}) async {
  final menuRepository = MenuRepository();
  await menuRepository.seedDefaultMenu();

  final orderRepository = OrderRepository();
  final startedAt = DateTime.now();

  return AppBootstrapContext(
    role: role,
    deviceConfig: deviceConfig,
    appInstanceId: _buildAppInstanceId(role, startedAt),
    startedAt: startedAt,
    menuRepository: menuRepository,
    orderRepository: orderRepository,
  );
}

String _buildAppInstanceId(AppRole role, DateTime startedAt) {
  final timestamp = startedAt.millisecondsSinceEpoch;
  return '${role.name}_$timestamp';
}
