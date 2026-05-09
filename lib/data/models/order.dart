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
  });

  Map<String, dynamic> toMap() {
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
    };
  }

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
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
    );
  }
}
