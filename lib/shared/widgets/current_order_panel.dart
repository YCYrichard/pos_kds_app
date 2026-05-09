import 'package:flutter/material.dart';

import '../../features/frontdesk/frontdesk_controller.dart';

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
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('目前尚未加入品項'),
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
                title: Text('${items[i].itemCode} ${items[i].itemName} x${items[i].qty}'),
                subtitle: Text(
                  items[i].spicyLevel == null ? '辣度：未選' : '辣度：${items[i].spicyLevel!.name}',
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
