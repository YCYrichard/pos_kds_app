import 'dart:async';

enum OrderEventType { created }

class OrderEvent {
  final OrderEventType type;
  final DateTime createdAt;

  const OrderEvent({required this.type, required this.createdAt});

  factory OrderEvent.orderCreated() {
    return OrderEvent(type: OrderEventType.created, createdAt: DateTime.now());
  }
}

class OrderEventBus {
  OrderEventBus._();

  static final OrderEventBus instance = OrderEventBus._();

  final StreamController<OrderEvent> _controller =
      StreamController<OrderEvent>.broadcast();

  Stream<OrderEvent> get stream => _controller.stream;

  void emitOrderCreated() {
    if (!_controller.isClosed) {
      _controller.add(OrderEvent.orderCreated());
    }
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
