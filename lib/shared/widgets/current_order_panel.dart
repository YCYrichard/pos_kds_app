import 'package:flutter/material.dart';

import '../../domain/enums/spicy_level.dart';
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

  String _spicyLevelText(BuildContext context, SpicyLevel level) {
    final l10n = context.l10n;

    // 請把這裡的 enum case 名稱改成你專案實際使用的值
    switch (level) {
      case SpicyLevel.mild:
        return l10n.spicyMild;
      case SpicyLevel.medium:
        return l10n.spicyMedium;
      case SpicyLevel.hot:
        return l10n.spicyHot;
    }
  }

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
                      : l10n.spicyPrefix(
                          _spicyLevelText(context, items[i].spicyLevel!),
                        ),
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
