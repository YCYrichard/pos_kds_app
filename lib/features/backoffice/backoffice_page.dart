import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/order_item.dart';
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
    return Consumer<BackofficeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('後台摘要'),
            actions: [
              IconButton(
                onPressed: controller.loadDashboard,
                icon: const Icon(Icons.refresh),
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
                          '訂單列表',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (controller.orders.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(controller.message ?? '目前沒有訂單紀錄'),
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
    final summary = controller.summary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '今日訂單',
                value: '${summary.todayOrders}',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '待完成',
                value: '${summary.pendingOrders}',
                icon: Icons.pending_actions_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          label: '今日營收',
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
    final order = bundle.order;
    final subtitle = order.orderType == 'dineIn'
        ? '內用｜桌號 ${order.tableNo ?? '-'}'
        : '外帶｜取餐號 ${order.pickupNo ?? '-'}';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet<void>(
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
              Text('建立時間：${_formatDateTime(order.createdAt)}'),
              const SizedBox(height: 4),
              Text('總品項數：${order.totalItems}'),
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
                Text('訂單明細', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _DetailRow(label: '訂單編號', value: order.orderNo),
                _DetailRow(
                  label: '訂單類型',
                  value: order.orderType == 'dineIn' ? '內用' : '外帶',
                ),
                if (order.orderType == 'dineIn')
                  _DetailRow(label: '桌號', value: order.tableNo ?? '-'),
                if (order.orderType == 'takeaway')
                  _DetailRow(label: '取餐號', value: order.pickupNo ?? '-'),
                _DetailRow(label: '狀態', value: _statusText(order.status)),
                _DetailRow(
                  label: '建立時間',
                  value: _formatDateTime(order.createdAt),
                ),
                if (order.completedAt != null)
                  _DetailRow(
                    label: '完成時間',
                    value: _formatDateTime(order.completedAt!),
                  ),
                const SizedBox(height: 16),
                Text('品項', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...bundle.items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${item.itemCode}｜${item.itemName}'),
                      subtitle: Text(_itemSubtitle(item)),
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
    final label = _statusText(status);

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

String _statusText(String status) {
  switch (status) {
    case 'completed':
      return '已完成';
    case 'preparing':
      return '製作中';
    default:
      return '已建立';
  }
}

String _itemSubtitle(OrderItemEntity item) {
  final spicy = item.spicyLevel == null ? '不辣度設定' : '辣度 ${item.spicyLevel}';
  return '數量 ${item.qty}｜$spicy';
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
