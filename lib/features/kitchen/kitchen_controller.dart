import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/order_event_bus.dart';
import '../../data/repositories/order_repository.dart';

class KitchenOrderBundle {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const KitchenOrderBundle({
    required this.order,
    required this.items,
  });
}

class KitchenMessage {
  static const String noPendingOrders = 'noPendingOrders';
  static const String itemCompleted = 'itemCompleted';
  static const String loadFailed = 'loadFailed';
}

class KitchenController extends ChangeNotifier {
  KitchenController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository {
    _orderEventSubscription = OrderEventBus.instance.stream.listen(
      _handleOrderEvent,
    );
  }

  final OrderRepository _orderRepository;
  StreamSubscription<OrderEvent>? _orderEventSubscription;

  bool _loading = false;
  bool _refreshQueued = false;
  String? _messageKey;
  List<KitchenOrderBundle> _orders = <KitchenOrderBundle>[];
  KitchenSortOption _sortOption = KitchenSortOption.oldestFirst;

  bool get loading => _loading;
  String? get messageKey => _messageKey;
  List<KitchenOrderBundle> get orders =>
      List<KitchenOrderBundle>.unmodifiable(_orders);
  KitchenSortOption get sortOption => _sortOption;

  void _clearMessage() {
    _messageKey = null;
  }

  void _setMessage(String key) {
    _messageKey = key;
  }

  Future<void> loadOrders() async {
    if (_loading) {
      _refreshQueued = true;
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final bundles = await _orderRepository.getActiveOrderBundles(
        sortOption: _sortOption,
      );

      _orders = bundles
          .map(
            (e) => KitchenOrderBundle(
              order: e.order,
              items: e.items,
            ),
          )
          .toList();

      if (_orders.isEmpty) {
        _setMessage(KitchenMessage.noPendingOrders);
      } else if (_messageKey != KitchenMessage.itemCompleted) {
        _clearMessage();
      }
    } catch (_) {
      _orders = <KitchenOrderBundle>[];
      _setMessage(KitchenMessage.loadFailed);
    } finally {
      _loading = false;
      notifyListeners();

      if (_refreshQueued) {
        _refreshQueued = false;
        unawaited(loadOrders());
      }
    }
  }

  Future<void> setSortOption(KitchenSortOption value) async {
    if (_sortOption == value) {
      return;
    }

    _sortOption = value;
    await loadOrders();
  }

  Future<void> completeItem(int itemId) async {
    try {
      await _orderRepository.completeOrderItem(itemId);
      await loadOrders();
      _setMessage(KitchenMessage.itemCompleted);
      notifyListeners();
    } catch (_) {
      _setMessage(KitchenMessage.loadFailed);
      notifyListeners();
    }
  }

  void _handleOrderEvent(OrderEvent event) {
    switch (event.type) {
      case OrderEventType.created:
        unawaited(loadOrders());
        break;
      default:
        unawaited(loadOrders());
        break;
    }
  }

  @override
  void dispose() {
    _orderEventSubscription?.cancel();
    super.dispose();
  }
}
