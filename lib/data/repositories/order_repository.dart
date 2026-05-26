import 'package:sqflite/sqflite.dart';

import '../db/database_provider.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../order_event_bus.dart';

enum KitchenSortOption { oldestFirst, newestFirst }

class OrderBundle {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const OrderBundle({
    required this.order,
    required this.items,
  });
}

class OrderDashboardSummary {
  final int todayOrders;
  final int pendingOrders;
  final int todayRevenue;

  const OrderDashboardSummary({
    required this.todayOrders,
    required this.pendingOrders,
    required this.todayRevenue,
  });
}

class OrderRepository {
  OrderRepository({
    required DatabaseGetter databaseGetter,
  }) : _databaseGetter = databaseGetter;

  final DatabaseGetter _databaseGetter;

  Future<int> createOrder({
    required OrderEntity order,
    required List<OrderItemEntity> items,
  }) async {
    final Database db = await _databaseGetter();

    final int orderId = await db.transaction<int>((Transaction txn) async {
      final int createdOrderId = await txn.insert('orders', order.toMap());

      for (final OrderItemEntity item in items) {
        await txn.insert(
          'order_items',
          OrderItemEntity(
            orderId: createdOrderId,
            itemCode: item.itemCode,
            itemName: item.itemName,
            qty: item.qty,
            spicyLevel: item.spicyLevel,
            status: item.status,
            completedAt: item.completedAt,
          ).toMap(),
        );
      }

      return createdOrderId;
    });

    OrderEventBus.instance.emitOrderCreated(orderId: orderId);
    return orderId;
  }

  Future<List<OrderEntity>> getActiveOrders({
    KitchenSortOption sortOption = KitchenSortOption.oldestFirst,
  }) async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'orders',
      where: 'status != ?',
      whereArgs: <Object>['completed'],
      orderBy: sortOption == KitchenSortOption.newestFirst
          ? 'created_at DESC'
          : 'created_at ASC',
    );

    return result.map(OrderEntity.fromMap).toList();
  }

  Future<List<OrderBundle>> getActiveOrderBundles({
    KitchenSortOption sortOption = KitchenSortOption.oldestFirst,
  }) async {
    final List<OrderEntity> orders =
        await getActiveOrders(sortOption: sortOption);
    final List<OrderBundle> bundles = <OrderBundle>[];

    for (final OrderEntity order in orders) {
      if (order.id == null) {
        continue;
      }

      final List<OrderItemEntity> items = await getOrderItems(order.id!);
      bundles.add(
        OrderBundle(
          order: order,
          items: items,
        ),
      );
    }

    return bundles;
  }

  Future<List<OrderEntity>> getAllOrders() async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'orders',
      orderBy: 'created_at DESC',
    );

    return result.map(OrderEntity.fromMap).toList();
  }

  Future<List<OrderBundle>> getAllOrderBundles() async {
    final List<OrderEntity> orders = await getAllOrders();
    final List<OrderBundle> bundles = <OrderBundle>[];

    for (final OrderEntity order in orders) {
      if (order.id == null) {
        continue;
      }

      final List<OrderItemEntity> items = await getOrderItems(order.id!);
      bundles.add(
        OrderBundle(
          order: order,
          items: items,
        ),
      );
    }

    return bundles;
  }

  Future<List<OrderItemEntity>> getOrderItems(int orderId) async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: <Object>[orderId],
      orderBy: 'id ASC',
    );

    return result.map(OrderItemEntity.fromMap).toList();
  }

  Future<List<String>> getOccupiedTableNumbers() async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'orders',
      columns: <String>['table_no'],
      where: '''
order_type = ?
AND status != ?
AND released_at IS NULL
AND table_no IS NOT NULL
AND table_no != ?
''',
      whereArgs: <Object>['dineIn', 'completed', ''],
    );

    final Set<String> tableSet = <String>{};

    for (final Map<String, Object?> row in result) {
      final String value = (row['table_no'] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        tableSet.add(value);
      }
    }

    final List<String> tables = tableSet.toList()..sort();
    return tables;
  }

  Future<int> getNextTakeawaySerial() async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> result = await db.query(
      'orders',
      columns: <String>['pickup_no'],
      where: 'order_type = ? AND pickup_no IS NOT NULL AND pickup_no != ?',
      whereArgs: <Object>['takeaway', ''],
      orderBy: 'id DESC',
    );

    int maxSerial = 100;

    for (final Map<String, Object?> row in result) {
      final String raw = (row['pickup_no'] as String?)?.trim() ?? '';
      final int? parsed = int.tryParse(raw);
      if (parsed != null && parsed > maxSerial) {
        maxSerial = parsed;
      }
    }

    return maxSerial + 1;
  }

  Future<void> releaseTable(String tableNo) async {
    final Database db = await _databaseGetter();
    await db.update(
      'orders',
      <String, Object?>{
        'released_at': DateTime.now().toIso8601String(),
      },
      where: '''
order_type = ?
AND status != ?
AND released_at IS NULL
AND table_no = ?
''',
      whereArgs: <Object>['dineIn', 'completed', tableNo],
    );

    OrderEventBus.instance.emitTableReleased(tableNo: tableNo);
  }

  Future<void> completeOrderItem(int itemId) async {
    final Database db = await _databaseGetter();

    await db.update(
      'order_items',
      <String, Object?>{
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object>[itemId],
    );

    final List<Map<String, Object?>> itemRow = await db.query(
      'order_items',
      where: 'id = ?',
      whereArgs: <Object>[itemId],
      limit: 1,
    );

    if (itemRow.isEmpty) {
      return;
    }

    final int orderId = itemRow.first['order_id'] as int;
    await refreshOrderStatus(orderId);

    OrderEventBus.instance.emitOrderUpdated(
      orderId: orderId,
      orderItemId: itemId,
    );
  }

  Future<void> refreshOrderStatus(int orderId) async {
    final Database db = await _databaseGetter();
    final List<Map<String, Object?>> items = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: <Object>[orderId],
    );

    if (items.isEmpty) {
      return;
    }

    final bool allCompleted =
        items.every((Map<String, Object?> e) => e['status'] == 'completed');
    final bool anyCompleted =
        items.any((Map<String, Object?> e) => e['status'] == 'completed');

    if (allCompleted) {
      await db.update(
        'orders',
        <String, Object?>{
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: <Object>[orderId],
      );
    } else if (anyCompleted) {
      await db.update(
        'orders',
        <String, Object?>{
          'status': 'preparing',
        },
        where: 'id = ?',
        whereArgs: <Object>[orderId],
      );
    }

    OrderEventBus.instance.emitOrderUpdated(orderId: orderId);
  }

  Future<OrderDashboardSummary> getDashboardSummary() async {
    final Database db = await _databaseGetter();

    final DateTime now = DateTime.now();
    final String todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String();
    final String tomorrowStart = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).toIso8601String();

    final List<Map<String, Object?>> totalOrdersResult = await db.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM orders
WHERE created_at >= ? AND created_at < ?
''',
      <Object>[todayStart, tomorrowStart],
    );

    final List<Map<String, Object?>> pendingOrdersResult = await db.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM orders
WHERE status != 'completed'
''',
    );

    final List<Map<String, Object?>> revenueResult = await db.rawQuery(
      '''
SELECT COALESCE(SUM(mi.price * oi.qty), 0) AS total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items mi ON mi.item_code = oi.item_code
WHERE o.created_at >= ? AND o.created_at < ?
''',
      <Object>[todayStart, tomorrowStart],
    );

    return OrderDashboardSummary(
      todayOrders: (totalOrdersResult.first['count'] as int?) ?? 0,
      pendingOrders: (pendingOrdersResult.first['count'] as int?) ?? 0,
      todayRevenue: (revenueResult.first['total'] as int?) ?? 0,
    );
  }
}
