import 'dart:convert';

class SyncEvent {
  const SyncEvent({
    required this.eventId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payloadJson,
    required this.hlc,
    required this.createdAt,
  });

  final String eventId;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String action;
  final String payloadJson;
  final String hlc;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'event_id': eventId,
      'device_id': deviceId,
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload_json': payloadJson,
      'hlc': hlc,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static SyncEvent fromMap(Map<String, Object?> map) {
    return SyncEvent(
      eventId: map['event_id'] as String,
      deviceId: map['device_id'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      action: map['action'] as String,
      payloadJson: map['payload_json'] as String,
      hlc: map['hlc'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 建立一筆新的事件（簡化版 HLC：timestamp + deviceId）
  static SyncEvent create({
    required String deviceId,
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, Object?> payload,
  }) {
    final DateTime now = DateTime.now().toUtc();
    final String timestamp = now.toIso8601String();

    return SyncEvent(
      // 注意：這裡不再用 '\_'，直接用 '_' 即可
      eventId: '${deviceId}_${timestamp}_$action',
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      action: action,
      payloadJson: jsonEncode(payload),
      hlc: '${timestamp}_$deviceId',
      createdAt: now,
    );
  }
}
