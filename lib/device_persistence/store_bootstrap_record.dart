import '../app_role.dart';

class StoreBootstrapRecord {
  const StoreBootstrapRecord({
    required this.deviceId,
    required this.installedRole,
    this.storeId,
    this.storeName,
    this.hostUrl,
    this.hostDeviceId,
    this.joinedAt,
  });

  final String deviceId;
  final AppRole installedRole;
  final String? storeId;
  final String? storeName;
  final String? hostUrl;
  final String? hostDeviceId;
  final String? joinedAt;

  bool get isConfigured {
    final String? normalizedStoreId = storeId?.trim();
    return normalizedStoreId != null && normalizedStoreId.isNotEmpty;
  }

  StoreBootstrapRecord copyWith({
    String? deviceId,
    AppRole? installedRole,
    String? storeId,
    bool clearStoreId = false,
    String? storeName,
    bool clearStoreName = false,
    String? hostUrl,
    bool clearHostUrl = false,
    String? hostDeviceId,
    bool clearHostDeviceId = false,
    String? joinedAt,
    bool clearJoinedAt = false,
  }) {
    return StoreBootstrapRecord(
      deviceId: deviceId ?? this.deviceId,
      installedRole: installedRole ?? this.installedRole,
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
      storeName: clearStoreName ? null : (storeName ?? this.storeName),
      hostUrl: clearHostUrl ? null : (hostUrl ?? this.hostUrl),
      hostDeviceId:
          clearHostDeviceId ? null : (hostDeviceId ?? this.hostDeviceId),
      joinedAt: clearJoinedAt ? null : (joinedAt ?? this.joinedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'installedRole': installedRole.name,
      'storeId': storeId,
      'storeName': storeName,
      'hostUrl': hostUrl,
      'hostDeviceId': hostDeviceId,
      'joinedAt': joinedAt,
    };
  }

  factory StoreBootstrapRecord.fromMap(Map<String, dynamic> map) {
    return StoreBootstrapRecord(
      deviceId: map['deviceId'] as String,
      installedRole: AppRole.values.byName(map['installedRole'] as String),
      storeId: map['storeId'] as String?,
      storeName: map['storeName'] as String?,
      hostUrl: map['hostUrl'] as String?,
      hostDeviceId: map['hostDeviceId'] as String?,
      joinedAt: map['joinedAt'] as String?,
    );
  }

  factory StoreBootstrapRecord.initialFromDevice({
    required String deviceId,
    required AppRole installedRole,
  }) {
    return StoreBootstrapRecord(
      deviceId: deviceId,
      installedRole: installedRole,
    );
  }
}
