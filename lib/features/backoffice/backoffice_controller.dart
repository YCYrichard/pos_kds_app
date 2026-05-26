import 'package:flutter/foundation.dart';
import 'package:pos_kds_app/data/models/menu_item.dart';
import 'package:pos_kds_app/data/models/order.dart';
import 'package:pos_kds_app/data/models/order_item.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';

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
  static const String menuLoadFailed = 'menuLoadFailed';
  static const String menuSaveFailed = 'menuSaveFailed';
}

class BackofficeController extends ChangeNotifier {
  BackofficeController({
    required OrderRepository orderRepository,
    required MenuRepository menuRepository,
  })  : _orderRepository = orderRepository,
        _menuRepository = menuRepository;

  final OrderRepository _orderRepository;
  final MenuRepository _menuRepository;

  bool _loading = false;
  bool _savingMenu = false;
  String? _messageKey;
  List<BackofficeOrderBundle> _orders = const <BackofficeOrderBundle>[];
  List<MenuItem> _menuItems = const <MenuItem>[];

  OrderDashboardSummary _summary = const OrderDashboardSummary(
    todayOrders: 0,
    pendingOrders: 0,
    todayRevenue: 0,
  );

  bool get loading => _loading;
  bool get savingMenu => _savingMenu;
  String? get messageKey => _messageKey;
  List<BackofficeOrderBundle> get orders => List.unmodifiable(_orders);
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
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
      final OrderDashboardSummary summary =
          await _orderRepository.getDashboardSummary();
      final List<OrderBundle> bundles =
          await _orderRepository.getAllOrderBundles();

      _summary = summary;
      _orders = bundles
          .map(
            (OrderBundle bundle) => BackofficeOrderBundle(
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

  Future<void> loadMenuItems() async {
    _clearMessage();

    try {
      _menuItems = await _menuRepository.getAll();
      notifyListeners();
    } catch (_) {
      _setMessage(BackofficeMessage.menuLoadFailed);
      notifyListeners();
    }
  }

  Future<void> saveMenuItem(MenuItem item) async {
    _savingMenu = true;
    _clearMessage();
    notifyListeners();

    try {
      await _menuRepository.upsertMenuItem(item);
      _menuItems = await _menuRepository.getAll();
    } catch (_) {
      _setMessage(BackofficeMessage.menuSaveFailed);
    } finally {
      _savingMenu = false;
      notifyListeners();
    }
  }

  Future<void> toggleMenuItemActive(MenuItem item) async {
    _savingMenu = true;
    _clearMessage();
    notifyListeners();

    try {
      await _menuRepository.setMenuItemActive(
        item.itemCode,
        !item.isActive,
      );
      _menuItems = await _menuRepository.getAll();
    } catch (_) {
      _setMessage(BackofficeMessage.menuSaveFailed);
    } finally {
      _savingMenu = false;
      notifyListeners();
    }
  }
}
