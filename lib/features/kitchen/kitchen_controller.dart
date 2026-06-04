import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/order_event_bus.dart';
import '../../data/repositories/order_repository.dart';
import '../../network/network_session.dart';

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
  KitchenController({
    required OrderRepository orderRepository,
    NetworkSession? networkSession,
  })  : _orderRepository = orderRepository,
        _networkSession = networkSession {
    if (!_shouldUseRemoteOrderMirror) {
      _orderEventSubscription = OrderEventBus.instance.stream.listen(
        _handleOrderEvent,
      );
    }
  }

  final OrderRepository _orderRepository;
  final NetworkSession? _networkSession;
  StreamSubscription<OrderEvent>? _orderEventSubscription;

  bool _loading = false;
  bool _refreshQueued = false;
  String? _messageKey;
  List<KitchenOrderBundle> _orders = <KitchenOrderBundle>[];
  KitchenSortOption _sortOption = KitchenSortOption.oldestFirst;

  int _debugLoadCallCount = 0;
  int _debugBundleCount = 0;
  int _debugOrderCount = 0;
  String? _debugLastError;
  DateTime? _debugLastLoadAt;

  bool get loading => _loading;
  String? get messageKey => _messageKey;
  List<KitchenOrderBundle> get orders =>
      List<KitchenOrderBundle>.unmodifiable(_orders);
  KitchenSortOption get sortOption => _sortOption;

  int get debugLoadCallCount => _debugLoadCallCount;
  int get debugBundleCount => _debugBundleCount;
  int get debugOrderCount => _debugOrderCount;
  String? get debugLastError => _debugLastError;
  DateTime? get debugLastLoadAt => _debugLastLoadAt;

  bool get _shouldUseRemoteOrderMirror =>
      _networkSession?.isClient == true &&
      _networkSession?.orderMirrorSyncService != null;

  void _clearMessage() {
    _messageKey = null;
  }

  void _setMessage(String key) {
    _messageKey = key;
  }

  Future<void> loadOrders() async {
    _debugLoadCallCount++;
    debugPrint(
      'KitchenController.loadOrders call=$_debugLoadCallCount loading=$_loading remoteMirror=$_shouldUseRemoteOrderMirror',
    );

    if (_loading) {
      _refreshQueued = true;
      debugPrint(
        'KitchenController.loadOrders already loading, queued=true',
      );
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      if (_shouldUseRemoteOrderMirror) {
        await _networkSession!.orderMirrorSyncService!.syncActiveOrdersOnce();
      }

      final bundles = await _orderRepository.getActiveOrderBundles(
        sortOption: _sortOption,
      );

      _debugBundleCount = bundles.length;

      _orders = bundles
          .map(
            (e) => KitchenOrderBundle(
              order: e.order,
              items: e.items,
            ),
          )
          .toList();

      _debugOrderCount = _orders.length;
      _debugLastError = null;

      debugPrint(
        'KitchenController.loadOrders bundles=$_debugBundleCount orders=$_debugOrderCount',
      );

      if (_orders.isEmpty) {
        _setMessage(KitchenMessage.noPendingOrders);
      } else if (_messageKey != KitchenMessage.itemCompleted) {
        _clearMessage();
      }
    } catch (e, st) {
      _debugLastError = e.toString();
      debugPrint('KitchenController.loadOrders error: $e');
      debugPrint('$st');
      _orders = <KitchenOrderBundle>[];
      _setMessage(KitchenMessage.loadFailed);
    } finally {
      _debugLastLoadAt = DateTime.now();
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
      if (_shouldUseRemoteOrderMirror) {
        await _networkSession!.orderMirrorSyncService!
            .completeOrderItemAndRefresh(itemId);
      } else {
        await _orderRepository.completeOrderItem(itemId);
      }

      await loadOrders();
      _setMessage(KitchenMessage.itemCompleted);
      notifyListeners();
    } catch (e, st) {
      _debugLastError = e.toString();
      debugPrint('KitchenController.completeItem error: $e');
      debugPrint('$st');
      _setMessage(KitchenMessage.loadFailed);
      notifyListeners();
    }
  }

  void _handleOrderEvent(OrderEvent event) {
    debugPrint('KitchenController._handleOrderEvent type=${event.type}');
    unawaited(loadOrders());
  }

  @override
  void dispose() {
    _orderEventSubscription?.cancel();
    super.dispose();
  }
}
