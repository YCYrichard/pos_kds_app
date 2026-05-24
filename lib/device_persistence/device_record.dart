import '../app_role.dart';
import '../sync_mode.dart';

class DeviceRecord {
  const DeviceRecord({
    required this.deviceId,
    required this.deviceName,
    required this.installedRole,
    required this.allowRoleOverride,
    required this.allowedRuntimeRoles,
    required this.defaultSyncMode,
    this.hostDeviceId,
  });

  final String deviceId;
  final String deviceName;
  final AppRole installedRole;
  final bool allowRoleOverride;
  final Set<AppRole> allowedRuntimeRoles;
  final SyncMode defaultSyncMode;
  final String? hostDeviceId;

  DeviceRecord copyWith({
    String? deviceId,
    String? deviceName,
    AppRole? installedRole,
    bool? allowRoleOverride,
    Set<AppRole>? allowedRuntimeRoles,
    SyncMode? defaultSyncMode,
    String? hostDeviceId,
    bool clearHostDeviceId = false,
  }) {
    return DeviceRecord(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      installedRole: installedRole ?? this.installedRole,
      allowRoleOverride: allowRoleOverride ?? this.allowRoleOverride,
      allowedRuntimeRoles: allowedRuntimeRoles ?? this.allowedRuntimeRoles,
      defaultSyncMode: defaultSyncMode ?? this.defaultSyncMode,
      hostDeviceId:
          clearHostDeviceId ? null : (hostDeviceId ?? this.hostDeviceId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'installedRole': installedRole.name,
      'allowRoleOverride': allowRoleOverride,
      'allowedRuntimeRoles': allowedRuntimeRoles.map((e) => e.name).toList(),
      'defaultSyncMode': defaultSyncMode.name,
      'hostDeviceId': hostDeviceId,
    };
  }

  factory DeviceRecord.fromMap(Map<String, dynamic> map) {
    return DeviceRecord(
      deviceId: map['deviceId'] as String,
      deviceName: map['deviceName'] as String,
      installedRole: AppRole.values.byName(map['installedRole'] as String),
      allowRoleOverride: map['allowRoleOverride'] as bool? ?? false,
      allowedRuntimeRoles:
          ((map['allowedRuntimeRoles'] as List<dynamic>? ?? []).cast<String>())
              .map(AppRole.values.byName)
              .toSet(),
      defaultSyncMode: SyncMode.values.byName(map['defaultSyncMode'] as String),
      hostDeviceId: map['hostDeviceId'] as String?,
    );
  }
}
