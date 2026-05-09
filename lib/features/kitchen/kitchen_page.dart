import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/order_repository.dart';
import '../../shared/widgets/kitchen_order_card.dart';
import 'kitchen_controller.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          KitchenController(orderRepository: context.read<OrderRepository>())
            ..loadOrders(),
      child: const _KitchenView(),
    );
  }
}

class _KitchenView extends StatefulWidget {
  const _KitchenView();

  @override
  State<_KitchenView> createState() => _KitchenViewState();
}

class _KitchenViewState extends State<_KitchenView> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      final controller = context.read<KitchenController>();
      if (!controller.loading) {
        controller.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
        );
      },
    );
  }
}
