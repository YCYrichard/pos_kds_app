// lib/data/models/order_item.dart

class OrderItemEntity {
  final int? id;
  final int orderId;
  final String itemCode;
  final String itemName;
  final int qty;
  final String? spicyLevel;
  final String status;
  final String? completedAt;
  final int? unitPrice;
  final String? storeId;
  final String? deviceId;
  final String? updatedAt;
  final String? syncStatus;

  const OrderItemEntity({
    this.id,
    required this.orderId,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    this.spicyLevel,
    required this.status,
    this.completedAt,
    this.unitPrice,
    this.storeId,
    this.deviceId,
    this.updatedAt,
    this.syncStatus,
  });

  OrderItemEntity copyWith({
    int? id,
    int? orderId,
    String? itemCode,
    String? itemName,
    int? qty,
    String? spicyLevel,
    bool clearSpicyLevel = false,
    String? status,
    String? completedAt,
    bool clearCompletedAt = false,
    int? unitPrice,
    bool clearUnitPrice = false,
    String? storeId,
    bool clearStoreId = false,
    String? deviceId,
    bool clearDeviceId = false,
    String? updatedAt,
    bool clearUpdatedAt = false,
    String? syncStatus,
    bool clearSyncStatus = false,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      spicyLevel: clearSpicyLevel ? null : (spicyLevel ?? this.spicyLevel),
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
      deviceId: clearDeviceId ? null : (deviceId ?? this.deviceId),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      syncStatus: clearSyncStatus ? null : (syncStatus ?? this.syncStatus),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_code': itemCode,
      'item_name': itemName,
      'qty': qty,
      'spicy_level': spicyLevel,
      'status': status,
      'completed_at': completedAt,
      'unit_price': unitPrice,
      'store_id': storeId,
      'device_id': deviceId,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
    };
  }

  factory OrderItemEntity.fromMap(Map<String, dynamic> map) {
    return OrderItemEntity(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      itemCode: map['item_code'] as String,
      itemName: map['item_name'] as String,
      qty: map['qty'] as int,
      spicyLevel: map['spicy_level'] as String?,
      status: map['status'] as String,
      completedAt: map['completed_at'] as String?,
      unitPrice: map['unit_price'] as int?,
      storeId: map['store_id'] as String?,
      deviceId: map['device_id'] as String?,
      updatedAt: map['updated_at'] as String?,
      syncStatus: map['sync_status'] as String?,
    );
  }
}
