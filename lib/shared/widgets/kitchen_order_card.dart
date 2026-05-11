import 'package:flutter/material.dart';

import '../../data/models/order_item.dart';
import '../../features/kitchen/kitchen_controller.dart';
import '../../l10n/l10n.dart';

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
    final l10n = context.l10n;
    final order = bundle.order;
    final items = bundle.items;

    final localizedOrderType = order.orderType == 'dineIn'
        ? l10n.orderTypeDineIn
        : l10n.orderTypeTakeaway;

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
                    l10n.orderPrefix(order.orderNo),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.typePrefix(localizedOrderType)),
            if (order.tableNo != null && order.tableNo!.isNotEmpty)
              Text(l10n.tablePrefix(order.tableNo!)),
            if (order.pickupNo != null && order.pickupNo!.isNotEmpty)
              Text(l10n.pickupPrefix(order.pickupNo!)),
            Text('${l10n.createdTime}: ${order.createdAt}'),
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
    final l10n = context.l10n;
    final completed = item.status == 'completed';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${item.itemCode} ${item.itemName} x${item.qty}'),
      subtitle: Text(
        item.spicyLevel == null || item.spicyLevel!.isEmpty
            ? l10n.spicyNotSelected
            : l10n.spicyPrefix(item.spicyLevel!),
      ),
      trailing: completed
          ? const Icon(Icons.check_circle, color: Colors.green)
          : FilledButton.tonal(
              onPressed:
                  item.id == null ? null : () => onCompleteItem(item.id!),
              child: Text(l10n.completeAction),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final color = switch (status) {
      'completed' => Colors.green,
      'preparing' => Colors.orange,
      _ => Colors.blueGrey,
    };

    final label = switch (status) {
      'completed' => l10n.statusCompleted,
      'preparing' => l10n.statusPreparing,
      _ => l10n.statusCreated,
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
