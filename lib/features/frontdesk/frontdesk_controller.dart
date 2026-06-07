import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/events/order_event_bus.dart';
import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/enums/order_type.dart';
import '../../domain/enums/spicy_level.dart';
import '../../network/network_session.dart';

class DraftOrderItem {
  final String itemCode;
  final String itemName;
  final int qty;
  final SpicyLevel? spicyLevel;

  const DraftOrderItem({
    required this.itemCode,
    required this.itemName,
    this.qty = 1,
    this.spicyLevel,
  });

  DraftOrderItem copyWith({
    String? itemCode,
    String? itemName,
    int? qty,
    SpicyLevel? spicyLevel,
    bool clearSpicyLevel = false,
  }) {
    return DraftOrderItem(
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      qty: qty ?? this.qty,
      spicyLevel: clearSpicyLevel ? null : (spicyLevel ?? this.spicyLevel),
    );
  }
}

class FrontdeskMessage {
  static const String releaseTableDone = 'releaseTableDone';
  static const String enterItemCodeFirst = 'enterItemCodeFirst';
  static const String itemCodeNotFound = 'itemCodeNotFound';
  static const String itemAdded = 'itemAdded';
  static const String itemRemoved = 'itemRemoved';
  static const String orderNeedsAtLeastOneItem = 'orderNeedsAtLeastOneItem';
  static const String dineInSelectTable = 'dineInSelectTable';
  static const String takeawaySerialNotReady = 'takeawaySerialNotReady';
  static const String orderSubmitted = 'orderSubmitted';
}

class FrontdeskController extends ChangeNotifier {
  FrontdeskController({
    required MenuRepository menuRepository,
    required OrderRepository orderRepository,
    NetworkSession? networkSession,
  })  : _menuRepository = menuRepository,
        _orderRepository = orderRepository,
        _networkSession = networkSession {
    _orderEventSubscription = OrderEventBus.instance.stream.listen(
      _handleOrderEvent,
    );
    loadServiceOptions();
    _startMenuSyncPollingIfNeeded();
  }

  static const List<String> _allTables = [
    'A1',
    'A2',
    'A3',
    'A4',
    'B1',
    'B2',
    'B3',
    'B4',
  ];

  final MenuRepository _menuRepository;
  final OrderRepository _orderRepository;
  final NetworkSession? _networkSession;

  StreamSubscription<OrderEvent>? _orderEventSubscription;
  Timer? _menuSyncTimer;

  OrderType _orderType = OrderType.dineIn;
  String _tableNo = '';
  String _pickupNo = '';
  String _itemCodeInput = '';
  SpicyLevel? _selectedSpicyLevel;
  bool _isSubmitting = false;
  bool _isLoadingOptions = false;
  bool _isReleasingTable = false;
  bool _refreshQueued = false;

  String? _messageKey;
  Map<String, String> _messageArgs = <String, String>{};

  List<String> _availableTables = List<String>.of(_allTables);
  List<String> _occupiedTables = const <String>[];
  final List<DraftOrderItem> _items = <DraftOrderItem>[];

  OrderType get orderType => _orderType;
  String get tableNo => _tableNo;
  String get pickupNo => _pickupNo;
  String get itemCodeInput => _itemCodeInput;
  SpicyLevel? get selectedSpicyLevel => _selectedSpicyLevel;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingOptions => _isLoadingOptions;
  bool get isReleasingTable => _isReleasingTable;

  String? get messageKey => _messageKey;
  Map<String, String> get messageArgs =>
      Map<String, String>.unmodifiable(_messageArgs);

  List<DraftOrderItem> get items => List<DraftOrderItem>.unmodifiable(_items);
  List<String> get availableTables =>
      List<String>.unmodifiable(_availableTables);
  List<String> get occupiedTables => List<String>.unmodifiable(_occupiedTables);

  int get totalQty => _items.fold<int>(0, (sum, item) => sum + item.qty);

  void _clearMessage() {
    _messageKey = null;
    _messageArgs = <String, String>{};
  }

  void _setMessage(String key,
      [Map<String, String> args = const <String, String>{}]) {
    _messageKey = key;
    _messageArgs = args;
  }

  Future<void> loadServiceOptions() async {
    if (_isLoadingOptions) {
      _refreshQueued = true;
      return;
    }

    _isLoadingOptions = true;
    notifyListeners();

    try {
      await _syncMenuIfNeeded();

      final occupiedTables = await _orderRepository.getOccupiedTableNumbers();
      final nextTakeawaySerial = await _orderRepository.getNextTakeawaySerial();

      _occupiedTables = occupiedTables;
      _availableTables =
          _allTables.where((table) => !occupiedTables.contains(table)).toList();

      if (_tableNo.isNotEmpty && !_availableTables.contains(_tableNo)) {
        _tableNo = '';
      }

      if (_orderType == OrderType.dineIn &&
          _tableNo.isEmpty &&
          _availableTables.isNotEmpty) {
        _tableNo = _availableTables.first;
      }

      _pickupNo = nextTakeawaySerial.toString();
      _clearMessage();
    } finally {
      _isLoadingOptions = false;
      notifyListeners();

      if (_refreshQueued) {
        _refreshQueued = false;
        unawaited(loadServiceOptions());
      }
    }
  }

  Future<void> releaseTable(String tableNo) async {
    if (_isReleasingTable) {
      return;
    }

    _isReleasingTable = true;
    _clearMessage();
    notifyListeners();

    try {
      await _orderRepository.releaseTable(tableNo);
      await loadServiceOptions();
      _setMessage(
        FrontdeskMessage.releaseTableDone,
        <String, String>{'tableNo': tableNo},
      );
    } finally {
      _isReleasingTable = false;
      notifyListeners();
    }
  }

  void setOrderType(OrderType value) {
    _orderType = value;
    _clearMessage();

    if (_orderType == OrderType.dineIn &&
        _tableNo.isEmpty &&
        _availableTables.isNotEmpty) {
      _tableNo = _availableTables.first;
    }

    notifyListeners();
  }

  void setPickupNo(String value) {
    _pickupNo = value;
    _clearMessage();
    notifyListeners();
  }

  void appendItemCodeDigit(String digit) {
    if (_itemCodeInput.length >= 3) {
      return;
    }

    _itemCodeInput += digit;
    _clearMessage();
    notifyListeners();
  }

  void backspaceItemCode() {
    if (_itemCodeInput.isEmpty) {
      return;
    }

    _itemCodeInput = _itemCodeInput.substring(0, _itemCodeInput.length - 1);
    notifyListeners();
  }

  void clearItemCode() {
    _itemCodeInput = '';
    notifyListeners();
  }

  void setTableNo(String value) {
    _tableNo = value.toUpperCase();
    _clearMessage();
    notifyListeners();
  }

  void setSpicyLevel(SpicyLevel? value) {
    _selectedSpicyLevel = value;
    _clearMessage();
    notifyListeners();
  }

  Future<bool> addCurrentItem() async {
    _clearMessage();

    await _syncMenuIfNeeded();

    if (_itemCodeInput.trim().isEmpty) {
      _setMessage(FrontdeskMessage.enterItemCodeFirst);
      notifyListeners();
      return false;
    }

    final inputCode = _itemCodeInput.trim();
    final menuItem = await _menuRepository.getByCode(inputCode);
    if (menuItem == null) {
      _setMessage(
        FrontdeskMessage.itemCodeNotFound,
        <String, String>{'itemCode': inputCode},
      );
      notifyListeners();
      return false;
    }

    final index = _items.indexWhere(
      (e) =>
          e.itemCode == menuItem.itemCode &&
          e.spicyLevel == _selectedSpicyLevel,
    );

    if (index >= 0) {
      _items[index] = _items[index].copyWith(qty: _items[index].qty + 1);
    } else {
      _items.add(
        DraftOrderItem(
          itemCode: menuItem.itemCode,
          itemName: menuItem.itemName,
          spicyLevel: _selectedSpicyLevel,
        ),
      );
    }

    _itemCodeInput = '';
    _selectedSpicyLevel = null;
    _setMessage(
      FrontdeskMessage.itemAdded,
      <String, String>{'itemName': menuItem.itemName},
    );
    notifyListeners();
    return true;
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final removed = _items.removeAt(index);
    _setMessage(
      FrontdeskMessage.itemRemoved,
      <String, String>{'itemName': removed.itemName},
    );
    notifyListeners();
  }

  Future<bool> submitOrder() async {
    if (_isSubmitting) {
      return false;
    }

    _clearMessage();

    if (_items.isEmpty) {
      _setMessage(FrontdeskMessage.orderNeedsAtLeastOneItem);
      notifyListeners();
      return false;
    }

    if (_orderType == OrderType.dineIn && _tableNo.trim().isEmpty) {
      _setMessage(FrontdeskMessage.dineInSelectTable);
      notifyListeners();
      return false;
    }

    if (_orderType == OrderType.takeaway && _pickupNo.trim().isEmpty) {
      _setMessage(FrontdeskMessage.takeawaySerialNotReady);
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final DateTime now = DateTime.now();
      final String orderNo = 'OD${now.millisecondsSinceEpoch}';

      final OrderEntity order = OrderEntity(
        orderNo: orderNo,
        orderType: _orderType.name,
        tableNo: _orderType == OrderType.dineIn ? _tableNo.trim() : null,
        pickupNo: _orderType == OrderType.takeaway ? _pickupNo.trim() : null,
        status: 'pending',
        totalItems: totalQty,
        createdAt: now.toIso8601String(),
        releasedAt: null,
      );

      final List<OrderItemEntity> orderItems = _items
          .map(
            (item) => OrderItemEntity(
              orderId: 0,
              itemCode: item.itemCode,
              itemName: item.itemName,
              qty: item.qty,
              spicyLevel: item.spicyLevel?.name,
              status: 'pending',
            ),
          )
          .toList();

      final hostClient = _networkSession?.hostClient;
      final bool submitToRemoteHost =
          _networkSession?.isClient == true && hostClient != null;

      if (submitToRemoteHost) {
        await hostClient.submitOrder(
          order: _buildRemoteOrderPayload(order),
          items: orderItems.map(_buildRemoteOrderItemPayload).toList(),
        );
      } else {
        await _orderRepository.createOrder(
          order: order,
          items: orderItems,
        );
      }

      _items.clear();
      _itemCodeInput = '';
      _selectedSpicyLevel = null;
      _setMessage(FrontdeskMessage.orderSubmitted);

      await loadServiceOptions();
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Map<String, Object?> _buildRemoteOrderPayload(OrderEntity order) {
    return <String, Object?>{
      'order_no': order.orderNo,
      'order_type': order.orderType,
      'table_no': order.tableNo,
      'pickup_no': order.pickupNo,
      'status': order.status,
      'total_items': order.totalItems,
      'created_at': order.createdAt,
      'completed_at': order.completedAt,
      'released_at': order.releasedAt,
    };
  }

  Map<String, Object?> _buildRemoteOrderItemPayload(OrderItemEntity item) {
    return <String, Object?>{
      'order_id': 0,
      'item_code': item.itemCode,
      'item_name': item.itemName,
      'qty': item.qty,
      'spicy_level': item.spicyLevel,
      'status': item.status,
      'completed_at': item.completedAt,
      'unit_price': item.unitPrice,
    };
  }

  Future<void> _syncMenuIfNeeded() async {
    final service = _networkSession?.menuSyncService;
    if (service == null) {
      return;
    }
    await service.syncOnce();
  }

  void _startMenuSyncPollingIfNeeded() {
    if (_networkSession?.menuSyncService == null) {
      return;
    }

    _menuSyncTimer?.cancel();
    _menuSyncTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(loadServiceOptions()),
    );
  }

  void _handleOrderEvent(OrderEvent event) {
    unawaited(loadServiceOptions());
  }

  @override
  void dispose() {
    _menuSyncTimer?.cancel();
    _orderEventSubscription?.cancel();
    super.dispose();
  }
}
