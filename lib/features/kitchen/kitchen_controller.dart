import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/repositories/order_repository.dart';

class KitchenOrderBundle {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const KitchenOrderBundle({required this.order, required this.items});
}

class KitchenController extends ChangeNotifier {
  KitchenController({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  final OrderRepository _orderRepository;

  bool _loading = false;
  String? _message;
  List<KitchenOrderBundle> _orders = [];
  KitchenSortOption _sortOption = KitchenSortOption.oldestFirst;

  bool get loading => _loading;
  String? get message => _message;
  List<KitchenOrderBundle> get orders => List.unmodifiable(_orders);
  KitchenSortOption get sortOption => _sortOption;

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
      _message = _orders.isEmpty ? '目前沒有待處理訂單' : null;
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
    _message = '品項已完成';
    notifyListeners();
  }
}
