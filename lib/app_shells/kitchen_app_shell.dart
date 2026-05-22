import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/order_repository.dart';
import '../features/kitchen/kitchen_controller.dart';
import '../features/kitchen/kitchen_page.dart';

class KitchenAppShell extends StatefulWidget {
  const KitchenAppShell({super.key});

  @override
  State<KitchenAppShell> createState() => _KitchenAppShellState();
}

class _KitchenAppShellState extends State<KitchenAppShell> {
  late final KitchenController _kitchenController;

  @override
  void initState() {
    super.initState();

    final orderRepository = context.read<OrderRepository>();

    _kitchenController = KitchenController(
      orderRepository: orderRepository,
    )..loadOrders();
  }

  @override
  void dispose() {
    _kitchenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KitchenController>.value(
      value: _kitchenController,
      child: const KitchenPage(isActive: true),
    );
  }
}
