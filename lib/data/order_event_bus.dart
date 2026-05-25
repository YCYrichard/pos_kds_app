import 'dart:async';

enum OrderEventType {
  created,
  updated,
  tableReleased,
}

class OrderEvent {
  final OrderEventType type;
  final DateTime createdAt;
  final int? orderId;
  final int? orderItemId;
  final String? tableNo;

  const OrderEvent({
    required this.type,
    required this.createdAt,
    this.orderId,
    this.orderItemId,
    this.tableNo,
  });

  factory OrderEvent.orderCreated({
    required int orderId,
  }) {
    return OrderEvent(
      type: OrderEventType.created,
      createdAt: DateTime.now(),
      orderId: orderId,
    );
  }

  factory OrderEvent.orderUpdated({
    required int orderId,
    int? orderItemId,
  }) {
    return OrderEvent(
      type: OrderEventType.updated,
      createdAt: DateTime.now(),
      orderId: orderId,
      orderItemId: orderItemId,
    );
  }

  factory OrderEvent.tableReleased({
    required String tableNo,
  }) {
    return OrderEvent(
      type: OrderEventType.tableReleased,
      createdAt: DateTime.now(),
      tableNo: tableNo,
    );
  }
}

class OrderEventBus {
  OrderEventBus._();

  static final OrderEventBus instance = OrderEventBus._();

  final StreamController<OrderEvent> _controller =
      StreamController<OrderEvent>.broadcast();

  Stream<OrderEvent> get stream => _controller.stream;

  void emitOrderCreated({
    required int orderId,
  }) {
    if (!_controller.isClosed) {
      _controller.add(
        OrderEvent.orderCreated(orderId: orderId),
      );
    }
  }

  void emitOrderUpdated({
    required int orderId,
    int? orderItemId,
  }) {
    if (!_controller.isClosed) {
      _controller.add(
        OrderEvent.orderUpdated(
          orderId: orderId,
          orderItemId: orderItemId,
        ),
      );
    }
  }

  void emitTableReleased({
    required String tableNo,
  }) {
    if (!_controller.isClosed) {
      _controller.add(
        OrderEvent.tableReleased(tableNo: tableNo),
      );
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
