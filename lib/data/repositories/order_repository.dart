import '../order_event_bus.dart';
import '../db/app_database.dart';
import '../models/order.dart';
import '../models/order_item.dart';

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
  Future<int> createOrder({
    required OrderEntity order,
    required List<OrderItemEntity> items,
  }) async {
    final db = await AppDatabase.database;

    final orderId = await db.transaction((txn) async {
      final createdOrderId = await txn.insert('orders', order.toMap());

      for (final item in items) {
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
    final db = await AppDatabase.database;
    final result = await db.query(
      'orders',
      where: 'status != ?',
      whereArgs: ['completed'],
      orderBy: sortOption == KitchenSortOption.newestFirst
          ? 'created_at DESC'
          : 'created_at ASC',
    );

    return result.map((row) => OrderEntity.fromMap(row)).toList();
  }

  Future<List<OrderBundle>> getActiveOrderBundles({
    KitchenSortOption sortOption = KitchenSortOption.oldestFirst,
  }) async {
    final orders = await getActiveOrders(sortOption: sortOption);
    final bundles = <OrderBundle>[];

    for (final order in orders) {
      if (order.id == null) continue;

      final items = await getOrderItems(order.id!);
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
    final db = await AppDatabase.database;
    final result = await db.query(
      'orders',
      orderBy: 'created_at DESC',
    );

    return result.map((row) => OrderEntity.fromMap(row)).toList();
  }

  Future<List<OrderBundle>> getAllOrderBundles() async {
    final orders = await getAllOrders();
    final bundles = <OrderBundle>[];

    for (final order in orders) {
      if (order.id == null) continue;

      final items = await getOrderItems(order.id!);
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
    final db = await AppDatabase.database;
    final result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'id ASC',
    );

    return result.map((row) => OrderItemEntity.fromMap(row)).toList();
  }

  Future<List<String>> getOccupiedTableNumbers() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'orders',
      columns: ['table_no'],
      where: '''
order_type = ?
AND status != ?
AND released_at IS NULL
AND table_no IS NOT NULL
AND table_no != ?
''',
      whereArgs: ['dineIn', 'completed', ''],
    );

    final tableSet = <String>{};

    for (final row in result) {
      final value = (row['table_no'] as String?)?.trim() ?? '';
      if (value.isNotEmpty) {
        tableSet.add(value);
      }
    }

    final tables = tableSet.toList()..sort();
    return tables;
  }

  Future<int> getNextTakeawaySerial() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'orders',
      columns: ['pickup_no'],
      where: 'order_type = ? AND pickup_no IS NOT NULL AND pickup_no != ?',
      whereArgs: ['takeaway', ''],
      orderBy: 'id DESC',
    );

    var maxSerial = 100;

    for (final row in result) {
      final raw = (row['pickup_no'] as String?)?.trim() ?? '';
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > maxSerial) {
        maxSerial = parsed;
      }
    }

    return maxSerial + 1;
  }

  Future<void> releaseTable(String tableNo) async {
    final db = await AppDatabase.database;
    await db.update(
      'orders',
      {'released_at': DateTime.now().toIso8601String()},
      where: '''
order_type = ?
AND status != ?
AND released_at IS NULL
AND table_no = ?
''',
      whereArgs: ['dineIn', 'completed', tableNo],
    );

    OrderEventBus.instance.emitTableReleased(tableNo: tableNo);
  }

  Future<void> completeOrderItem(int itemId) async {
    final db = await AppDatabase.database;

    await db.update(
      'order_items',
      {
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );

    final itemRow = await db.query(
      'order_items',
      where: 'id = ?',
      whereArgs: [itemId],
      limit: 1,
    );

    if (itemRow.isEmpty) return;

    final orderId = itemRow.first['order_id'] as int;
    await refreshOrderStatus(orderId);

    OrderEventBus.instance.emitOrderUpdated(
      orderId: orderId,
      orderItemId: itemId,
    );
  }

  Future<void> refreshOrderStatus(int orderId) async {
    final db = await AppDatabase.database;
    final items = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    if (items.isEmpty) return;

    final allCompleted = items.every((e) => e['status'] == 'completed');
    final anyCompleted = items.any((e) => e['status'] == 'completed');

    if (allCompleted) {
      await db.update(
        'orders',
        {
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [orderId],
      );
    } else if (anyCompleted) {
      await db.update(
        'orders',
        {'status': 'preparing'},
        where: 'id = ?',
        whereArgs: [orderId],
      );
    }

    OrderEventBus.instance.emitOrderUpdated(orderId: orderId);
  }

  Future<OrderDashboardSummary> getDashboardSummary() async {
    final db = await AppDatabase.database;

    final now = DateTime.now();
    final todayStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String();
    final tomorrowStart = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).toIso8601String();

    final totalOrdersResult = await db.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM orders
WHERE created_at >= ? AND created_at < ?
''',
      [todayStart, tomorrowStart],
    );

    final pendingOrdersResult = await db.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM orders
WHERE status != 'completed'
''',
    );

    final revenueResult = await db.rawQuery(
      '''
SELECT COALESCE(SUM(mi.price * oi.qty), 0) AS total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items mi ON mi.item_code = oi.item_code
WHERE o.created_at >= ? AND o.created_at < ?
''',
      [todayStart, tomorrowStart],
    );

    return OrderDashboardSummary(
      todayOrders: (totalOrdersResult.first['count'] as int?) ?? 0,
      pendingOrders: (pendingOrdersResult.first['count'] as int?) ?? 0,
      todayRevenue: (revenueResult.first['total'] as int?) ?? 0,
    );
  }
}
