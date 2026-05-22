import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'device_config.dart';
import 'role_policy_service.dart';
import 'sync_mode.dart';

Future<void> bootstrapApp(
  AppRole installedRole, {
  AppRole? requestedRole,
  String? hostDeviceId,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceConfig = _buildDeviceConfig(installedRole);
  final rolePolicyService = const RolePolicyService();
  final resolution = rolePolicyService.resolve(
    deviceConfig: deviceConfig,
    requestedRole: requestedRole,
    hostDeviceId: hostDeviceId,
  );

  final context = await _createBootstrapContext(
    deviceConfig: deviceConfig,
    runtimeRole: resolution.runtimeRole,
    resolvedSyncMode: resolution.resolvedSyncMode,
    resolutionReason: resolution.reason,
    hostDeviceId: resolution.hostDeviceId,
    takeoverSourceRole: resolution.takeoverSourceRole,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DeviceConfig>.value(value: deviceConfig),
        Provider<RolePolicyService>.value(value: rolePolicyService),
        Provider<AppBootstrapContext>.value(value: context),
        Provider<MenuRepository>.value(value: context.menuRepository),
        Provider<OrderRepository>.value(value: context.orderRepository),
      ],
      child: PosKdsApp(role: context.runtimeRole),
    ),
  );
}

DeviceConfig _buildDeviceConfig(AppRole installedRole) {
  switch (installedRole) {
    case AppRole.frontdesk:
      return const DeviceConfig(
        deviceId: 'frontdesk-device-01',
        deviceName: 'Frontdesk Terminal',
        installedRole: AppRole.frontdesk,
        allowedRuntimeRoles: {
          AppRole.frontdesk,
        },
        defaultSyncMode: SyncMode.standalone,
        allowRoleOverride: false,
      );
    case AppRole.kitchen:
      return const DeviceConfig(
        deviceId: 'kitchen-device-01',
        deviceName: 'Kitchen Terminal',
        installedRole: AppRole.kitchen,
        allowedRuntimeRoles: {
          AppRole.kitchen,
        },
        defaultSyncMode: SyncMode.standalone,
        allowRoleOverride: false,
      );
    case AppRole.backoffice:
      return const DeviceConfig(
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
    case AppRole.combined:
      return const DeviceConfig(
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
  }
}

Future<AppBootstrapContext> _createBootstrapContext({
  required DeviceConfig deviceConfig,
  required AppRole runtimeRole,
  required SyncMode resolvedSyncMode,
  required String resolutionReason,
  required String? hostDeviceId,
  required AppRole? takeoverSourceRole,
}) async {
  final menuRepository = MenuRepository();
  await menuRepository.seedDefaultMenu();

  final orderRepository = OrderRepository();
  final startedAt = DateTime.now();

  return AppBootstrapContext(
    deviceConfig: deviceConfig,
    runtimeRole: runtimeRole,
    resolvedSyncMode: resolvedSyncMode,
    appInstanceId: _buildAppInstanceId(
      deviceId: deviceConfig.deviceId,
      runtimeRole: runtimeRole,
      startedAt: startedAt,
    ),
    startedAt: startedAt,
    menuRepository: menuRepository,
    orderRepository: orderRepository,
    resolutionReason: resolutionReason,
    hostDeviceId: hostDeviceId,
    takeoverSourceRole: takeoverSourceRole,
  );
}

String _buildAppInstanceId({
  required String deviceId,
  required AppRole runtimeRole,
  required DateTime startedAt,
}) {
  final timestamp = startedAt.millisecondsSinceEpoch;
  return '${deviceId}_${runtimeRole.name}_$timestamp';
}
