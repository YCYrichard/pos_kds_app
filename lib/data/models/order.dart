// lib/data/models/order.dart

class OrderEntity {
  final int? id;
  final String orderNo;
  final String orderType;
  final String? tableNo;
  final String? pickupNo;
  final String status;
  final int totalItems;
  final String createdAt;
  final String? completedAt;
  final String? releasedAt;
  final String? storeId;
  final String? deviceId;
  final String? updatedAt;
  final String? syncStatus;

  const OrderEntity({
    this.id,
    required this.orderNo,
    required this.orderType,
    this.tableNo,
    this.pickupNo,
    required this.status,
    required this.totalItems,
    required this.createdAt,
    this.completedAt,
    this.releasedAt,
    this.storeId,
    this.deviceId,
    this.updatedAt,
    this.syncStatus,
  });

  OrderEntity copyWith({
    int? id,
    String? orderNo,
    String? orderType,
    String? tableNo,
    bool clearTableNo = false,
    String? pickupNo,
    bool clearPickupNo = false,
    String? status,
    int? totalItems,
    String? createdAt,
    String? completedAt,
    bool clearCompletedAt = false,
    String? releasedAt,
    bool clearReleasedAt = false,
    String? storeId,
    bool clearStoreId = false,
    String? deviceId,
    bool clearDeviceId = false,
    String? updatedAt,
    bool clearUpdatedAt = false,
    String? syncStatus,
    bool clearSyncStatus = false,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      orderType: orderType ?? this.orderType,
      tableNo: clearTableNo ? null : (tableNo ?? this.tableNo),
      pickupNo: clearPickupNo ? null : (pickupNo ?? this.pickupNo),
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      releasedAt: clearReleasedAt ? null : (releasedAt ?? this.releasedAt),
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
      deviceId: clearDeviceId ? null : (deviceId ?? this.deviceId),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      syncStatus: clearSyncStatus ? null : (syncStatus ?? this.syncStatus),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'order_no': orderNo,
      'order_type': orderType,
      'table_no': tableNo,
      'pickup_no': pickupNo,
      'status': status,
      'total_items': totalItems,
      'created_at': createdAt,
      'completed_at': completedAt,
      'released_at': releasedAt,
      'store_id': storeId,
      'device_id': deviceId,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory OrderEntity.fromMap(Map<String, Object?> map) {
    return OrderEntity(
      id: map['id'] as int?,
      orderNo: map['order_no'] as String,
      orderType: map['order_type'] as String,
      tableNo: map['table_no'] as String?,
      pickupNo: map['pickup_no'] as String?,
      status: map['status'] as String,
      totalItems: map['total_items'] as int,
      createdAt: map['created_at'] as String,
      completedAt: map['completed_at'] as String?,
      releasedAt: map['released_at'] as String?,
      storeId: map['store_id'] as String?,
      deviceId: map['device_id'] as String?,
      updatedAt: map['updated_at'] as String?,
      syncStatus: map['sync_status'] as String?,
    );
  }
}
