import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/order_event_bus.dart';
import '../../data/repositories/order_repository.dart';

enum BackofficeMessage {
  none,
  noOrderRecords,
  loadFailed,
}

class BackofficeOrderBundle {
  final OrderBundle bundle;

  const BackofficeOrderBundle({
    required this.bundle,
  });

  get order => bundle.order;
  get items => bundle.items;
}

class BackofficeController extends ChangeNotifier {
  BackofficeController({
    required OrderRepository orderRepository,
  }) : _orderRepository = orderRepository {
    _orderEventSubscription = OrderEventBus.instance.stream.listen(
      _handleOrderEvent,
    );
  }

  final OrderRepository _orderRepository;

  StreamSubscription<OrderEvent>? _orderEventSubscription;

  bool _loading = false;
  bool _refreshQueued = false;
  BackofficeMessage _messageKey = BackofficeMessage.none;
  OrderDashboardSummary _summary = const OrderDashboardSummary(
    todayOrders: 0,
    pendingOrders: 0,
    todayRevenue: 0,
  );
  List<BackofficeOrderBundle> _orders = const [];

  bool get loading => _loading;
  BackofficeMessage get messageKey => _messageKey;
  OrderDashboardSummary get summary => _summary;
  List<BackofficeOrderBundle> get orders => _orders;

  Future<void> loadDashboard() async {
    if (_loading) {
      _refreshQueued = true;
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final summary = await _orderRepository.getDashboardSummary();
      final bundles = await _orderRepository.getAllOrderBundles();

      _summary = summary;
      _orders = bundles
          .map(
            (bundle) => BackofficeOrderBundle(bundle: bundle),
          )
          .toList();

      _messageKey = _orders.isEmpty
          ? BackofficeMessage.noOrderRecords
          : BackofficeMessage.none;
    } catch (_) {
      _summary = const OrderDashboardSummary(
        todayOrders: 0,
        pendingOrders: 0,
        todayRevenue: 0,
      );
      _orders = const [];
      _messageKey = BackofficeMessage.loadFailed;
    } finally {
      _loading = false;
      notifyListeners();

      if (_refreshQueued) {
        _refreshQueued = false;
        unawaited(loadDashboard());
      }
    }
  }

  void _handleOrderEvent(OrderEvent event) {
    switch (event.type) {
      case OrderEventType.created:
      case OrderEventType.updated:
      case OrderEventType.tableReleased:
        unawaited(loadDashboard());
        break;
    }
  }

  @override
  void dispose() {
    _orderEventSubscription?.cancel();
    super.dispose();
  }
}
