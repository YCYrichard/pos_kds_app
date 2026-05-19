import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/repositories/order_repository.dart';

class BackofficeOrderBundle {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const BackofficeOrderBundle({
    required this.order,
    required this.items,
  });
}

class BackofficeController extends ChangeNotifier {
  BackofficeController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  final OrderRepository _orderRepository;

  bool _loading = false;
  String? _message;
  List<BackofficeOrderBundle> _orders = const <BackofficeOrderBundle>[];
  OrderDashboardSummary _summary = const OrderDashboardSummary(
    todayOrders: 0,
    pendingOrders: 0,
    todayRevenue: 0,
  );

  bool get loading => _loading;
  String? get message => _message;
  List<BackofficeOrderBundle> get orders =>
      List<BackofficeOrderBundle>.unmodifiable(_orders);
  OrderDashboardSummary get summary => _summary;

  Future<void> loadDashboard() async {
    _loading = true;
    _message = null;
    notifyListeners();

    try {
      final summary = await _orderRepository.getDashboardSummary();
      final bundles = await _orderRepository.getAllOrderBundles();

      _summary = summary;
      _orders = bundles
          .map(
            (bundle) => BackofficeOrderBundle(
              order: bundle.order,
              items: bundle.items,
            ),
          )
          .toList();

      _message = _orders.isEmpty ? '目前沒有訂單紀錄' : null;
    } catch (_) {
      _message = '後台資料載入失敗';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
