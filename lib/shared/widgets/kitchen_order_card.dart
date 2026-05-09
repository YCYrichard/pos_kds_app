import 'package:flutter/material.dart';

import '../../data/models/order_item.dart';
import '../../features/kitchen/kitchen_controller.dart';

class KitchenOrderCard extends StatelessWidget {
  const KitchenOrderCard({
    super.key,
    required this.bundle,
    required this.onCompleteItem,
  });

  final KitchenOrderBundle bundle;
  final ValueChanged<int> onCompleteItem;

  @override
  Widget build(BuildContext context) {
    final order = bundle.order;
    final items = bundle.items;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '訂單 ${order.orderNo}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('類型：${order.orderType}'),
            if (order.tableNo != null && order.tableNo!.isNotEmpty)
              Text('桌號：${order.tableNo}'),
            if (order.pickupNo != null && order.pickupNo!.isNotEmpty)
              Text('取餐號：${order.pickupNo}'),
            Text('建立時間：${order.createdAt}'),
            const Divider(height: 24),
            for (final item in items)
              _OrderItemTile(item: item, onCompleteItem: onCompleteItem),
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item, required this.onCompleteItem});

  final OrderItemEntity item;
  final ValueChanged<int> onCompleteItem;

  @override
  Widget build(BuildContext context) {
    final completed = item.status == 'completed';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${item.itemCode} ${item.itemName} x${item.qty}'),
      subtitle: Text(item.spicyLevel == null || item.spicyLevel!.isEmpty ? '辣度：未選' : '辣度：${item.spicyLevel}'),
      trailing: completed
          ? const Icon(Icons.check_circle, color: Colors.green)
          : FilledButton.tonal(
              onPressed: item.id == null ? null : () => onCompleteItem(item.id!),
              child: const Text('完成'),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'completed' => Colors.green,
      'preparing' => Colors.orange,
      _ => Colors.blueGrey,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
