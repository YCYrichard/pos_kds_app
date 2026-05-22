import 'app_role.dart';
import 'sync_mode.dart';

class RoleResolution {
  const RoleResolution({
    required this.runtimeRole,
    required this.resolvedSyncMode,
    required this.reason,
    this.hostDeviceId,
    this.takeoverSourceRole,
  });

  final AppRole runtimeRole;
  final SyncMode resolvedSyncMode;
  final String reason;
  final String? hostDeviceId;
  final AppRole? takeoverSourceRole;
}
