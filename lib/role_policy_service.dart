import 'app_role.dart';
import 'device_config.dart';
import 'role_resolution.dart';
import 'sync_mode.dart';

class RolePolicyService {
  const RolePolicyService();

  RoleResolution resolve({
    required DeviceConfig deviceConfig,
    AppRole? requestedRole,
    String? hostDeviceId,
  }) {
    final fallbackRole = deviceConfig.installedRole;
    final targetRole = requestedRole ?? fallbackRole;

    final canUseRequestedRole = _canUseRequestedRole(
      deviceConfig: deviceConfig,
      requestedRole: targetRole,
    );

    final runtimeRole = canUseRequestedRole ? targetRole : fallbackRole;
    final reason = _buildReason(
      deviceConfig: deviceConfig,
      requestedRole: requestedRole,
      runtimeRole: runtimeRole,
      fallbackRole: fallbackRole,
      hostDeviceId: hostDeviceId,
    );

    final resolvedSyncMode = _resolveSyncMode(
      deviceConfig: deviceConfig,
      runtimeRole: runtimeRole,
      hostDeviceId: hostDeviceId,
    );

    return RoleResolution(
      runtimeRole: runtimeRole,
      resolvedSyncMode: resolvedSyncMode,
      reason: reason,
      hostDeviceId: hostDeviceId,
      takeoverSourceRole: runtimeRole == fallbackRole ? null : fallbackRole,
    );
  }

  bool _canUseRequestedRole({
    required DeviceConfig deviceConfig,
    required AppRole requestedRole,
  }) {
    if (requestedRole == deviceConfig.installedRole) {
      return true;
    }

    if (!deviceConfig.allowRoleOverride) {
      return false;
    }

    return deviceConfig.allowedRuntimeRoles.contains(requestedRole);
  }

  SyncMode _resolveSyncMode({
    required DeviceConfig deviceConfig,
    required AppRole runtimeRole,
    required String? hostDeviceId,
  }) {
    if (hostDeviceId != null && hostDeviceId.isNotEmpty) {
      return SyncMode.client;
    }

    if (runtimeRole == AppRole.combined) {
      return SyncMode.host;
    }

    return deviceConfig.defaultSyncMode;
  }

  String _buildReason({
    required DeviceConfig deviceConfig,
    required AppRole? requestedRole,
    required AppRole runtimeRole,
    required AppRole fallbackRole,
    required String? hostDeviceId,
  }) {
    if (hostDeviceId != null && hostDeviceId.isNotEmpty) {
      return 'Client bootstrap due to host binding.';
    }

    if (requestedRole == null) {
      return 'No requested role. Using installed role.';
    }

    if (runtimeRole == requestedRole) {
      if (runtimeRole == fallbackRole) {
        return 'Requested role matches installed role.';
      }
      return 'Requested role allowed by device policy.';
    }

    return 'Requested role rejected by device policy. Falling back to installed role.';
  }
}
