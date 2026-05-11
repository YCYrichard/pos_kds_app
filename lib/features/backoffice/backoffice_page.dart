import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    if (!mounted) return;

    if (widget.isActive && !_didRefreshOnActivate) {
      _didRefreshOnActivate = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isActive) return;
        context.read<BackofficeController>().loadDashboard();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<BackofficeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.backofficeTitle),
            actions: [
              IconButton(
                onPressed: controller.loadDashboard,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.commonRefresh,
              ),
            ],
          ),
          body: SafeArea(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: controller.loadDashboard,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        _SummarySection(controller: controller),
                        const SizedBox(height: 16),
                        Text(
                          l10n.orderListTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (controller.orders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(
                                controller.message ?? l10n.noOrderRecords,
                              ),
                            ),
                          )
                        else
                          ...controller.orders.map(
                            (bundle) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderListCard(bundle: bundle),
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

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({required this.bundle});

  final BackofficeOrderBundle bundle;

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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) => _OrderDetailSheet(bundle: bundle),
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
              Text('${l10n.createdTime}: ${_formatDateTime(order.createdAt)}'),
              const SizedBox(height: 4),
              Text('${l10n.totalItems}: ${order.totalItems}'),
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
        builder: (context, scrollController) {
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
                      label: l10n.tableLabel, value: order.tableNo ?? '-'),
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
                  (item) => Card(
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
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
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
    final scheme = Theme.of(context).colorScheme;
    final label = _statusText(context, status);

    Color background;
    Color foreground;

    switch (status) {
      case 'completed':
        background = scheme.primaryContainer;
        foreground = scheme.onPrimaryContainer;
        break;
      case 'preparing':
        background = scheme.secondaryContainer;
        foreground = scheme.onSecondaryContainer;
        break;
      default:
        background = scheme.surfaceVariant;
        foreground = scheme.onSurfaceVariant;
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: background,
      labelStyle: TextStyle(color: foreground),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

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

String _itemSubtitle(BuildContext context, OrderItemEntity item) {
  final l10n = context.l10n;
  final spicy = item.spicyLevel == null
      ? l10n.noSpicyConfigured
      : l10n.spicyLevelValue(item.spicyLevel!);
  return l10n.quantityWithSpicy(item.qty, spicy);
}

String _formatDateTime(String value) {
  final dt = DateTime.tryParse(value);
  if (dt == null) return value;

  final mm = dt.month.toString().padLeft(2, '0');
  final dd = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$mm/$dd $hh:$mi';
}
