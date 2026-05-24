import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'app_session_state.dart';
import 'bootstrap_guard_mismatch.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'device_config.dart';
import 'device_persistence/device_config_store.dart';
import 'device_persistence/device_record.dart';
import 'role_policy_service.dart';
import 'sync_mode.dart';

Future<void> bootstrapApp(
  AppRole installedRole, {
  AppRole? requestedRole,
  String? hostDeviceId,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceConfigStore = DeviceConfigStore();
  final deviceRecord = await deviceConfigStore.loadOrCreate(installedRole);

  if (deviceRecord.installedRole != installedRole) {
    runApp(
      BootstrapGuardMismatchApp(
        expectedRole: installedRole,
        persistedRole: deviceRecord.installedRole,
        deviceId: deviceRecord.deviceId,
        deviceName: deviceRecord.deviceName,
        deviceConfigStore: deviceConfigStore,
      ),
    );
    return;
  }

  final deviceConfig = _toDeviceConfig(deviceRecord);

  final rolePolicyService = const RolePolicyService();
  final resolution = rolePolicyService.resolve(
    deviceConfig: deviceConfig,
    requestedRole: requestedRole,
    hostDeviceId: hostDeviceId ?? deviceRecord.hostDeviceId,
  );

  final context = await _createBootstrapContext(
    deviceConfig: deviceConfig,
    runtimeRole: resolution.runtimeRole,
    resolvedSyncMode: resolution.resolvedSyncMode,
    resolutionReason: resolution.reason,
    hostDeviceId: resolution.hostDeviceId,
    takeoverSourceRole: resolution.takeoverSourceRole,
  );

  final sessionState = AppSessionState(
    bootstrapContext: context,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<DeviceConfigStore>.value(value: deviceConfigStore),
        Provider<DeviceConfig>.value(value: deviceConfig),
        Provider<RolePolicyService>.value(value: rolePolicyService),
        Provider<AppBootstrapContext>.value(value: context),
        ChangeNotifierProvider<AppSessionState>.value(value: sessionState),
        Provider<MenuRepository>.value(value: context.menuRepository),
        Provider<OrderRepository>.value(value: context.orderRepository),
      ],
      child: PosKdsApp(role: context.runtimeRole),
    ),
  );
}

DeviceConfig _toDeviceConfig(DeviceRecord record) {
  return DeviceConfig(
    deviceId: record.deviceId,
    deviceName: record.deviceName,
    installedRole: record.installedRole,
    allowedRuntimeRoles: record.allowedRuntimeRoles,
    defaultSyncMode: record.defaultSyncMode,
    allowRoleOverride: record.allowRoleOverride,
  );
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
