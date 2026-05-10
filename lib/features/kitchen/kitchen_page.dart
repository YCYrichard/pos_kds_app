import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/events/order_event_bus.dart';
import '../../data/repositories/order_repository.dart';
import '../../shared/widgets/kitchen_order_card.dart';
import 'kitchen_controller.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return _KitchenView(isActive: isActive);
  }
}

class _KitchenView extends StatefulWidget {
  const _KitchenView({required this.isActive});

  final bool isActive;

  @override
  State<_KitchenView> createState() => _KitchenViewState();
}

class _KitchenViewState extends State<_KitchenView> {
  Timer? _refreshTimer;
  StreamSubscription<OrderEvent>? _orderEventSubscription;
  bool _didRefreshOnActivate = false;

  @override
  void initState() {
    super.initState();
    _subscribeToOrderEvents();
    _syncRefreshLifecycle();
  }

  @override
  void didUpdateWidget(covariant _KitchenView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _didRefreshOnActivate = false;
      }
      _syncRefreshLifecycle();
    }
  }

  void _subscribeToOrderEvents() {
    _orderEventSubscription?.cancel();
    _orderEventSubscription = OrderEventBus.instance.stream.listen((event) {
      if (!mounted) return;
      if (!widget.isActive) return;

      switch (event.type) {
        case OrderEventType.created:
          final controller = context.read<KitchenController>();
          if (!controller.loading) {
            controller.loadOrders();
          }
          break;
      }
    });
  }

  void _syncRefreshLifecycle() {
    if (!mounted) return;

    if (widget.isActive) {
      if (!_didRefreshOnActivate) {
        _didRefreshOnActivate = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !widget.isActive) return;
          final controller = context.read<KitchenController>();
          if (!controller.loading) {
            controller.loadOrders();
          }
        });
      }
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_refreshTimer != null) return;

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      if (!widget.isActive) return;

      final controller = context.read<KitchenController>();
      if (!controller.loading) {
        controller.loadOrders();
      }
    });
  }

  void _stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    _orderEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KitchenController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('後廚 KDS'),
            actions: [
              IconButton(
                onPressed: controller.loadOrders,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Text('排序', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<KitchenSortOption>(
                          value: controller.sortOption,
                          isExpanded: true,
                          onChanged: (value) {
                            if (value == null) return;
                            controller.setSortOption(value);
                          },
                          items: const [
                            DropdownMenuItem(
                              value: KitchenSortOption.oldestFirst,
                              child: Text('最早優先'),
                            ),
                            DropdownMenuItem(
                              value: KitchenSortOption.newestFirst,
                              child: Text('最新優先'),
                            ),
                            DropdownMenuItem(
                              value: KitchenSortOption.statusPriority,
                              child: Text('狀態優先'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.orders.isEmpty
                      ? Center(child: Text(controller.message ?? '目前沒有待處理訂單'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.orders.length,
                          itemBuilder: (context, index) {
                            final bundle = controller.orders[index];
                            return KitchenOrderCard(
                              bundle: bundle,
                              onCompleteItem: (itemId) async {
                                await controller.completeItem(itemId);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('品項已完成')),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
