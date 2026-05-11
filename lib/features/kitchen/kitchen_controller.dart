import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/repositories/order_repository.dart';

class KitchenOrderBundle {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const KitchenOrderBundle({required this.order, required this.items});
}

class KitchenMessage {
  static const String noPendingOrders = 'noPendingOrders';
  static const String itemCompleted = 'itemCompleted';
}

class KitchenController extends ChangeNotifier {
  KitchenController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  final OrderRepository _orderRepository;

  bool _loading = false;
  String? _messageKey;
  List<KitchenOrderBundle> _orders = [];
  KitchenSortOption _sortOption = KitchenSortOption.oldestFirst;

  bool get loading => _loading;
  String? get messageKey => _messageKey;
  List<KitchenOrderBundle> get orders => List.unmodifiable(_orders);
  KitchenSortOption get sortOption => _sortOption;

  void _clearMessage() {
    _messageKey = null;
  }

  void _setMessage(String key) {
    _messageKey = key;
  }

  Future<void> loadOrders() async {
    _loading = true;
    notifyListeners();

    try {
      final bundles = await _orderRepository.getActiveOrderBundles(
        sortOption: _sortOption,
      );
      _orders = bundles
          .map((e) => KitchenOrderBundle(order: e.order, items: e.items))
          .toList();

      if (_orders.isEmpty) {
        _setMessage(KitchenMessage.noPendingOrders);
      } else {
        _clearMessage();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> setSortOption(KitchenSortOption value) async {
    if (_sortOption == value) return;
    _sortOption = value;
    await loadOrders();
  }

  Future<void> completeItem(int itemId) async {
    await _orderRepository.completeOrderItem(itemId);
    await loadOrders();
    _setMessage(KitchenMessage.itemCompleted);
    notifyListeners();
  }
}
