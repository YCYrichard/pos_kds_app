import 'app_role.dart';

class DeviceConfig {
  const DeviceConfig({
    required this.deviceName,
    required this.installedRole,
    this.allowRoleOverride = false,
  });

  final String deviceName;
  final AppRole installedRole;
  final bool allowRoleOverride;
}
