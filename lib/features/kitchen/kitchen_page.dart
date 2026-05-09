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
      create: (_) => KitchenController(
        orderRepository: context.read<OrderRepository>(),
      )..loadOrders(),
      child: const _KitchenView(),
    );
  }
}

class _KitchenView extends StatelessWidget {
  const _KitchenView();

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
