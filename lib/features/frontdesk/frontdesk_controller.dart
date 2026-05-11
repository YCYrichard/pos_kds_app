import 'package:flutter/foundation.dart';

import '../../core/events/order_event_bus.dart';
import '../../data/models/order.dart';
import '../../data/models/order_item.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/enums/order_type.dart';
import '../../domain/enums/spicy_level.dart';

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

class FrontdeskController extends ChangeNotifier {
  FrontdeskController({
    required MenuRepository menuRepository,
    required OrderRepository orderRepository,
  })  : _menuRepository = menuRepository,
        _orderRepository = orderRepository {
    loadServiceOptions();
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

  OrderType _orderType = OrderType.dineIn;
  String _tableNo = '';
  String _pickupNo = '';
  String _itemCodeInput = '';
  SpicyLevel? _selectedSpicyLevel;
  bool _isSubmitting = false;
  bool _isLoadingOptions = false;
  bool _isReleasingTable = false;
  String? _message;
  List<String> _availableTables = List.of(_allTables);
  List<String> _occupiedTables = const [];
  final List<DraftOrderItem> _items = [];

  OrderType get orderType => _orderType;
  String get tableNo => _tableNo;
  String get pickupNo => _pickupNo;
  String get itemCodeInput => _itemCodeInput;
  SpicyLevel? get selectedSpicyLevel => _selectedSpicyLevel;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingOptions => _isLoadingOptions;
  bool get isReleasingTable => _isReleasingTable;
  String? get message => _message;
  List<DraftOrderItem> get items => List.unmodifiable(_items);
  List<String> get availableTables => List.unmodifiable(_availableTables);
  List<String> get occupiedTables => List.unmodifiable(_occupiedTables);

  int get totalQty => _items.fold(0, (sum, item) => sum + item.qty);

  Future<void> loadServiceOptions() async {
    _isLoadingOptions = true;
    notifyListeners();

    try {
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
      _message = null;
    } finally {
      _isLoadingOptions = false;
      notifyListeners();
    }
  }

  Future<void> releaseTable(String tableNo) async {
    if (_isReleasingTable) return;

    _isReleasingTable = true;
    _message = null;
    notifyListeners();

    try {
      await _orderRepository.releaseTable(tableNo);
      await loadServiceOptions();
      _message = '桌號 $tableNo 已釋放';
    } finally {
      _isReleasingTable = false;
      notifyListeners();
    }
  }

  void setOrderType(OrderType value) {
    _orderType = value;
    _message = null;

    if (_orderType == OrderType.dineIn &&
        _tableNo.isEmpty &&
        _availableTables.isNotEmpty) {
      _tableNo = _availableTables.first;
    }

    notifyListeners();
  }

  void setPickupNo(String value) {
    _pickupNo = value;
    _message = null;
    notifyListeners();
  }

  void appendItemCodeDigit(String digit) {
    if (_itemCodeInput.length >= 3) return;
    _itemCodeInput += digit;
    _message = null;
    notifyListeners();
  }

  void backspaceItemCode() {
    if (_itemCodeInput.isEmpty) return;
    _itemCodeInput = _itemCodeInput.substring(0, _itemCodeInput.length - 1);
    notifyListeners();
  }

  void clearItemCode() {
    _itemCodeInput = '';
    notifyListeners();
  }

  void setTableNo(String value) {
    _tableNo = value.toUpperCase();
    _message = null;
    notifyListeners();
  }

  void setSpicyLevel(SpicyLevel? value) {
    _selectedSpicyLevel = value;
    _message = null;
    notifyListeners();
  }

  Future<bool> addCurrentItem() async {
    _message = null;
    if (_itemCodeInput.trim().isEmpty) {
      _message = '請先輸入品項號碼';
      notifyListeners();
      return false;
    }

    final menuItem = await _menuRepository.getByCode(_itemCodeInput.trim());
    if (menuItem == null) {
      _message = '找不到品項號碼 ${_itemCodeInput.trim()}';
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
    _message = '已加入 ${menuItem.itemName}';
    notifyListeners();
    return true;
  }

  void removeItemAt(int index) {
    if (index < 0 || index >= _items.length) return;
    final removed = _items.removeAt(index);
    _message = '已移除 ${removed.itemName}';
    notifyListeners();
  }

  Future<bool> submitOrder() async {
    if (_isSubmitting) return false;
    _message = null;

    if (_items.isEmpty) {
      _message = '訂單至少需要一個品項';
      notifyListeners();
      return false;
    }

    if (_orderType == OrderType.dineIn && _tableNo.trim().isEmpty) {
      _message = '內用請選擇桌號';
      notifyListeners();
      return false;
    }

    if (_orderType == OrderType.takeaway && _pickupNo.trim().isEmpty) {
      _message = '外帶流水號尚未準備完成';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final orderNo = 'OD${now.millisecondsSinceEpoch}';

      await _orderRepository.createOrder(
        order: OrderEntity(
          orderNo: orderNo,
          orderType: _orderType.name,
          tableNo: _orderType == OrderType.dineIn ? _tableNo.trim() : null,
          pickupNo: _orderType == OrderType.takeaway ? _pickupNo.trim() : null,
          status: 'pending',
          totalItems: totalQty,
          createdAt: now.toIso8601String(),
          releasedAt: null,
        ),
        items: _items
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
            .toList(),
      );

      OrderEventBus.instance.emitOrderCreated();

      _items.clear();
      _itemCodeInput = '';
      _selectedSpicyLevel = null;
      _message = '訂單已送出';

      await loadServiceOptions();
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
