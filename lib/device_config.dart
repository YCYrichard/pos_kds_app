import 'app_role.dart';
import 'sync_mode.dart';

class DeviceConfig {
  const DeviceConfig({
    required this.deviceId,
    required this.deviceName,
    required this.installedRole,
    required this.allowedRuntimeRoles,
    required this.defaultSyncMode,
    this.allowRoleOverride = false,
  });

  final String deviceId;
  final String deviceName;
  final AppRole installedRole;
  final Set<AppRole> allowedRuntimeRoles;
  final SyncMode defaultSyncMode;
  final bool allowRoleOverride;
}
