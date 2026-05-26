import 'package:flutter/material.dart';

import '../../data/models/order_item.dart';
import '../../features/kitchen/kitchen_controller.dart';
import '../../l10n/l10n.dart';

String _statusText(BuildContext context, String status) {
  final l10n = context.l10n;

  switch (status) {
    case 'completed':
      return l10n.statusCompleted;
    case 'preparing':
      return l10n.statusPreparing;
    default:
      return l10n.statusCreated;
  }
}

String _orderTypeText(BuildContext context, String orderType) {
  final l10n = context.l10n;

  switch (orderType) {
    case 'takeaway':
      return l10n.orderTypeTakeaway;
    case 'dineIn':
    default:
      return l10n.orderTypeDineIn;
  }
}

String _spicyLevelText(BuildContext context, String? spicyLevel) {
  final l10n = context.l10n;

  if (spicyLevel == null || spicyLevel.isEmpty) {
    return l10n.spicyNotSelected;
  }

  switch (spicyLevel.toLowerCase()) {
    case 'mild':
      return l10n.spicyPrefix(l10n.spicyMild);
    case 'medium':
      return l10n.spicyPrefix(l10n.spicyMedium);
    case 'hot':
      return l10n.spicyPrefix(l10n.spicyHot);
    default:
      return l10n.spicyPrefix(spicyLevel);
  }
}

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
            Text(l10n.typePrefix(_orderTypeText(context, order.orderType))),
            Text('${l10n.statusLabel}：${_statusText(context, order.status)}'),
            if (order.tableNo != null && order.tableNo!.isNotEmpty)
              Text(l10n.tablePrefix(order.tableNo!)),
            if (order.pickupNo != null && order.pickupNo!.isNotEmpty)
              Text(l10n.pickupPrefix(order.pickupNo!)),
            Text('${l10n.createdTime}：${order.createdAt}'),
            const Divider(height: 24),
            for (final item in items)
              _OrderItemTile(
                item: item,
                onCompleteItem: onCompleteItem,
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    required this.onCompleteItem,
  });

  final OrderItemEntity item;
  final ValueChanged<int> onCompleteItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool completed = item.status == 'completed';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${item.itemCode} ${item.itemName} x${item.qty}'),
      subtitle: Text(_spicyLevelText(context, item.spicyLevel)),
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
    final Color color = switch (status) {
      'completed' => Colors.green,
      'preparing' => Colors.orange,
      _ => Colors.blueGrey,
    };

    return Chip(
      label: Text(_statusText(context, status)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}
