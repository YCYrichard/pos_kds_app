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
    final normalizedHostDeviceId = _normalizeNullable(hostDeviceId);
    final fallbackRole = deviceConfig.installedRole;
    final targetRole = requestedRole ?? fallbackRole;

    final canUseRequestedRole = _canUseRequestedRole(
      deviceConfig: deviceConfig,
      requestedRole: targetRole,
    );

    final runtimeRole = canUseRequestedRole ? targetRole : fallbackRole;

    final resolvedSyncMode = _resolveSyncMode(
      deviceConfig: deviceConfig,
      runtimeRole: runtimeRole,
      hostDeviceId: normalizedHostDeviceId,
    );

    final reason = _buildReason(
      deviceConfig: deviceConfig,
      requestedRole: requestedRole,
      runtimeRole: runtimeRole,
      fallbackRole: fallbackRole,
      hostDeviceId: normalizedHostDeviceId,
      resolvedSyncMode: resolvedSyncMode,
    );

    return RoleResolution(
      runtimeRole: runtimeRole,
      resolvedSyncMode: resolvedSyncMode,
      reason: reason,
      hostDeviceId: normalizedHostDeviceId,
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
    final bool boundToRemoteHost = hostDeviceId != null &&
        hostDeviceId.isNotEmpty &&
        hostDeviceId != deviceConfig.deviceId;

    if (boundToRemoteHost) {
      return SyncMode.client;
    }

    if (runtimeRole == AppRole.combined || runtimeRole == AppRole.frontdesk) {
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
    required SyncMode resolvedSyncMode,
  }) {
    final bool boundToRemoteHost = hostDeviceId != null &&
        hostDeviceId.isNotEmpty &&
        hostDeviceId != deviceConfig.deviceId;

    final bool boundToSelf = hostDeviceId != null &&
        hostDeviceId.isNotEmpty &&
        hostDeviceId == deviceConfig.deviceId;

    if (boundToRemoteHost) {
      if (requestedRole != null && runtimeRole != requestedRole) {
        return 'Client bootstrap due to remote host binding. Requested role rejected by device policy.';
      }

      if (requestedRole != null &&
          runtimeRole == requestedRole &&
          runtimeRole != fallbackRole) {
        return 'Client bootstrap due to remote host binding. Requested role allowed by device policy.';
      }

      return 'Client bootstrap due to remote host binding.';
    }

    if (resolvedSyncMode == SyncMode.host) {
      if (boundToSelf) {
        return 'Host bootstrap using self host binding.';
      }

      if (requestedRole == null) {
        return 'Host bootstrap using installed role.';
      }

      if (runtimeRole == requestedRole) {
        if (runtimeRole == fallbackRole) {
          return 'Host bootstrap with requested role matching installed role.';
        }
        return 'Host bootstrap with requested role allowed by device policy.';
      }

      return 'Host bootstrap after requested role was rejected by device policy.';
    }

    if (requestedRole == null) {
      return 'Standalone bootstrap using installed role.';
    }

    if (runtimeRole == requestedRole) {
      if (runtimeRole == fallbackRole) {
        return 'Requested role matches installed role.';
      }
      return 'Requested role allowed by device policy.';
    }

    return 'Requested role rejected by device policy. Falling back to installed role.';
  }

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
