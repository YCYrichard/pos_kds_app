class OrderItemEntity {
  final int? id;
  final int orderId;
  final String itemCode;
  final String itemName;
  final int qty;
  final String? spicyLevel;
  final String status;
  final String? completedAt;

  const OrderItemEntity({
    this.id,
    required this.orderId,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    this.spicyLevel,
    required this.status,
    this.completedAt,
  });

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
    );
  }
}
