// lib/data/models/device_config.dart

enum DeviceRole {
  standalone,
  storeHost,
  storePeer,
}

class DeviceConfig {
  final int? id;
  final String deviceId;
  final String? storeId;
  final DeviceRole role;
  final String? hostUrl;
  final String? displayName;
  final String createdAt;
  final String updatedAt;

  const DeviceConfig({
    this.id,
    required this.deviceId,
    required this.storeId,
    required this.role,
    this.hostUrl,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'store_id': storeId,
      'role': role.name,
      'host_url': hostUrl,
      'display_name': displayName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory DeviceConfig.fromMap(Map<String, Object?> map) {
    return DeviceConfig(
      id: map['id'] as int?,
      deviceId: map['device_id'] as String,
      storeId: map['store_id'] as String?,
      role: DeviceRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => DeviceRole.standalone,
      ),
      hostUrl: map['host_url'] as String?,
      displayName: map['display_name'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
