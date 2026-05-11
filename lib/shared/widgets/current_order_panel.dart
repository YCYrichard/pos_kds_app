import 'package:flutter/material.dart';

import '../../features/frontdesk/frontdesk_controller.dart';
import '../../l10n/l10n.dart';

class CurrentOrderPanel extends StatelessWidget {
  const CurrentOrderPanel({
    super.key,
    required this.items,
    required this.onRemove,
  });

  final List<DraftOrderItem> items;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.currentOrderEmpty),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${items[i].itemCode} ${items[i].itemName} x${items[i].qty}',
                ),
                subtitle: Text(
                  items[i].spicyLevel == null
                      ? l10n.spicyNotSelected
                      : l10n.spicyPrefix(items[i].spicyLevel!.name),
                ),
                trailing: IconButton(
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
