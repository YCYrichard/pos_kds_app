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

class BackofficeMessage {
  static const String noOrderRecords = 'noOrderRecords';
  static const String loadFailed = 'backofficeLoadFailed';
}

class BackofficeController extends ChangeNotifier {
  BackofficeController({required OrderRepository orderRepository})
      : _orderRepository = orderRepository;

  final OrderRepository _orderRepository;

  bool _loading = false;
  String? _messageKey;
  List<BackofficeOrderBundle> _orders = const <BackofficeOrderBundle>[];
  OrderDashboardSummary _summary = const OrderDashboardSummary(
    todayOrders: 0,
    pendingOrders: 0,
    todayRevenue: 0,
  );

  bool get loading => _loading;
  String? get messageKey => _messageKey;
  List<BackofficeOrderBundle> get orders =>
      List<BackofficeOrderBundle>.unmodifiable(_orders);
  OrderDashboardSummary get summary => _summary;

  void _clearMessage() {
    _messageKey = null;
  }

  void _setMessage(String key) {
    _messageKey = key;
  }

  Future<void> loadDashboard() async {
    _loading = true;
    _clearMessage();
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

      if (_orders.isEmpty) {
        _setMessage(BackofficeMessage.noOrderRecords);
      }
    } catch (_) {
      _setMessage(BackofficeMessage.loadFailed);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
