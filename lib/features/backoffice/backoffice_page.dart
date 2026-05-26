import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/menu_item.dart';
import '../../data/models/order_item.dart';
import '../../l10n/l10n.dart';
import 'backoffice_controller.dart';

class BackofficePage extends StatefulWidget {
  const BackofficePage({super.key, required this.isActive});

  final bool isActive;

  @override
  State<BackofficePage> createState() => _BackofficePageState();
}

class _BackofficePageState extends State<BackofficePage> {
  bool _didRefreshOnActivate = false;

  @override
  void initState() {
    super.initState();
    _syncLifecycleRefresh();
  }

  @override
  void didUpdateWidget(covariant BackofficePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _didRefreshOnActivate = false;
      }
      _syncLifecycleRefresh();
    }
  }

  void _syncLifecycleRefresh() {
    if (!mounted) {
      return;
    }

    if (widget.isActive && !_didRefreshOnActivate) {
      _didRefreshOnActivate = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isActive) {
          return;
        }
        final BackofficeController controller =
            context.read<BackofficeController>();
        controller.loadDashboard();
        controller.loadMenuItems();
      });
    }
  }

  String? _resolveBackofficeMessage(
    BuildContext context,
    BackofficeController controller,
  ) {
    final l10n = context.l10n;

    switch (controller.messageKey) {
      case BackofficeMessage.noOrderRecords:
        return l10n.noOrderRecords;
      case BackofficeMessage.loadFailed:
        return l10n.backofficeLoadFailed;
      case BackofficeMessage.menuLoadFailed:
        return '菜單載入失敗';
      case BackofficeMessage.menuSaveFailed:
        return '菜單儲存失敗';
      default:
        return null;
    }
  }

  Future<void> _showMenuItemEditor(
    BuildContext context,
    BackofficeController controller, {
    MenuItem? item,
  }) async {
    final TextEditingController codeController = TextEditingController(
      text: item?.itemCode ?? '',
    );
    final TextEditingController nameController = TextEditingController(
      text: item?.itemName ?? '',
    );
    final TextEditingController priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );
    bool isActive = item?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return AlertDialog(
              title: Text(item == null ? '新增菜單項目' : '編輯菜單項目'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      enabled: item == null,
                      decoration: const InputDecoration(
                        labelText: '品項代碼',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '品項名稱',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '價格',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('啟用'),
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    final String code = codeController.text.trim();
                    final String name = nameController.text.trim();
                    final int? price =
                        int.tryParse(priceController.text.trim());

                    if (code.isEmpty || name.isEmpty || price == null) {
                      return;
                    }

                    await controller.saveMenuItem(
                      MenuItem(
                        itemCode: code,
                        itemName: name,
                        price: price,
                        isActive: isActive,
                      ),
                    );

                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    nameController.dispose();
    priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<BackofficeController>(
      builder: (BuildContext context, BackofficeController controller, _) {
        final String? messageText =
            _resolveBackofficeMessage(context, controller);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.backofficeTitle),
            actions: [
              IconButton(
                onPressed: () async {
                  await controller.loadDashboard();
                  await controller.loadMenuItems();
                },
                icon: const Icon(Icons.refresh),
                tooltip: l10n.commonRefresh,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: controller.savingMenu
                ? null
                : () => _showMenuItemEditor(
                      context,
                      controller,
                    ),
            icon: const Icon(Icons.add),
            label: const Text('新增菜單'),
          ),
          body: SafeArea(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await controller.loadDashboard();
                      await controller.loadMenuItems();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        _SummarySection(controller: controller),
                        const SizedBox(height: 24),
                        Text(
                          l10n.orderListTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (controller.orders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Center(
                              child: Text(
                                messageText ?? l10n.noOrderRecords,
                              ),
                            ),
                          )
                        else
                          ...controller.orders.map(
                            (BackofficeOrderBundle bundle) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderListCard(bundle: bundle),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '菜單管理',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (controller.savingMenu)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (controller.menuItems.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('目前沒有菜單項目'),
                            ),
                          )
                        else
                          ...controller.menuItems.map(
                            (MenuItem item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MenuItemCard(
                                item: item,
                                onEdit: () => _showMenuItemEditor(
                                  context,
                                  controller,
                                  item: item,
                                ),
                                onToggleActive: () =>
                                    controller.toggleMenuItemActive(item),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.controller});

  final BackofficeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = controller.summary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: l10n.todayOrders,
                value: '${summary.todayOrders}',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: l10n.pendingOrders,
                value: '${summary.pendingOrders}',
                icon: Icons.pending_actions_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: l10n.todayRevenue,
          value: 'NT\$ ${summary.todayRevenue}',
          icon: Icons.attach_money_outlined,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.onEdit,
    required this.onToggleActive,
  });

  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${item.itemCode}｜${item.itemName}'),
        subtitle: Text('NT\$ ${item.price}'),
        leading: Icon(
          item.isActive ? Icons.check_circle : Icons.cancel_outlined,
          color: item.isActive ? Colors.green : Colors.grey,
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: '編輯',
            ),
            IconButton(
              onPressed: onToggleActive,
              icon: Icon(
                item.isActive
                    ? Icons.visibility_off_outlined
                    : Icons.visibility,
              ),
              tooltip: item.isActive ? '停用' : '啟用',
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({required this.bundle});

  final BackofficeOrderBundle bundle;

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = bundle.order;
    final subtitle = order.orderType == 'dineIn'
        ? l10n.dineInWithTable(order.tableNo ?? '-')
        : l10n.takeawayWithPickup(order.pickupNo ?? '-');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (BuildContext context) =>
                _OrderDetailSheet(bundle: bundle),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(subtitle),
              const SizedBox(height: 4),
              Text('${l10n.createdTime}：${_formatDateTime(order.createdAt)}'),
              const SizedBox(height: 4),
              Text('${l10n.totalItems}：${order.totalItems}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.bundle});

  final BackofficeOrderBundle bundle;

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

  String _spicyText(BuildContext context, String? spicyLevel) {
    final l10n = context.l10n;

    if (spicyLevel == null || spicyLevel.isEmpty) {
      return l10n.noSpicyConfigured;
    }

    switch (spicyLevel.toLowerCase()) {
      case 'mild':
        return l10n.spicyLevelValue(l10n.spicyMild);
      case 'medium':
        return l10n.spicyLevelValue(l10n.spicyMedium);
      case 'hot':
        return l10n.spicyLevelValue(l10n.spicyHot);
      default:
        return l10n.spicyLevelValue(spicyLevel);
    }
  }

  String _itemSubtitle(BuildContext context, OrderItemEntity item) {
    final l10n = context.l10n;
    return l10n.quantityWithSpicy(
      item.qty.toString(),
      _spicyText(context, item.spicyLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = bundle.order;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  l10n.orderDetailTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _DetailRow(label: l10n.orderNumber, value: order.orderNo),
                _DetailRow(
                  label: l10n.orderTypeLabel,
                  value: order.orderType == 'dineIn'
                      ? l10n.orderTypeDineIn
                      : l10n.orderTypeTakeaway,
                ),
                if (order.orderType == 'dineIn')
                  _DetailRow(
                    label: l10n.tableLabel,
                    value: order.tableNo ?? '-',
                  ),
                if (order.orderType == 'takeaway')
                  _DetailRow(
                    label: l10n.pickupLabel,
                    value: order.pickupNo ?? '-',
                  ),
                _DetailRow(
                  label: l10n.statusLabel,
                  value: _statusText(context, order.status),
                ),
                _DetailRow(
                  label: l10n.createdTime,
                  value: _formatDateTime(order.createdAt),
                ),
                if (order.completedAt != null)
                  _DetailRow(
                    label: l10n.completedTime,
                    value: _formatDateTime(order.completedAt!),
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.itemsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...bundle.items.map(
                  (OrderItemEntity item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${item.itemCode}｜${item.itemName}'),
                      subtitle: Text(_itemSubtitle(context, item)),
                      trailing: _StatusChip(status: item.status),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
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

    final String label;
    final Color color;

    switch (status) {
      case 'completed':
        label = l10n.statusCompleted;
        color = Colors.green;
        break;
      case 'preparing':
        label = l10n.statusPreparing;
        color = Colors.orange;
        break;
      default:
        label = l10n.statusCreated;
        color = Colors.blueGrey;
        break;
    }

    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}

String _formatDateTime(String value) {
  final DateTime? dateTime = DateTime.tryParse(value);
  if (dateTime == null) {
    return value;
  }

  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}/${dateTime.month}/${dateTime.day} $hour:$minute';
}
