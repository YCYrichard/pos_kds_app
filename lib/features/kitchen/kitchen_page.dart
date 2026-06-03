import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/events/order_event_bus.dart';
import '../../data/repositories/order_repository.dart';
import '../../l10n/l10n.dart';
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
  StreamSubscription? _orderEventSubscription;
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
        default:
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

  String? _resolveKitchenMessage(
    BuildContext context,
    KitchenController controller,
  ) {
    final l10n = context.l10n;

    switch (controller.messageKey) {
      case KitchenMessage.noPendingOrders:
        return l10n.noPendingOrders;
      case KitchenMessage.itemCompleted:
        return l10n.itemCompleted;
      case KitchenMessage.loadFailed:
        return l10n.commonLoadFailed;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _orderEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<KitchenController>(
      builder: (context, controller, _) {
        final messageText = _resolveKitchenMessage(context, controller);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.kitchenTitle),
            actions: [
              IconButton(
                onPressed: controller.loadOrders,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.commonRefresh,
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
                      Text(
                        l10n.sortLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<KitchenSortOption>(
                          value: controller.sortOption,
                          isExpanded: true,
                          onChanged: (value) {
                            if (value == null) return;
                            controller.setSortOption(value);
                          },
                          items: [
                            DropdownMenuItem(
                              value: KitchenSortOption.oldestFirst,
                              child: Text(l10n.sortOldestFirst),
                            ),
                            DropdownMenuItem(
                              value: KitchenSortOption.newestFirst,
                              child: Text(l10n.sortNewestFirst),
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
                          ? Center(
                              child: Text(messageText ?? l10n.noPendingOrders),
                            )
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
                                      SnackBar(
                                        content: Text(
                                          _resolveKitchenMessage(
                                                context,
                                                controller,
                                              ) ??
                                              l10n.itemCompleted,
                                        ),
                                      ),
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
