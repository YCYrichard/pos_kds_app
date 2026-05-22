import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/order_repository.dart';
import '../features/backoffice/backoffice_controller.dart';
import '../features/backoffice/backoffice_page.dart';

class BackofficeAppShell extends StatefulWidget {
  const BackofficeAppShell({super.key});

  @override
  State<BackofficeAppShell> createState() => _BackofficeAppShellState();
}

class _BackofficeAppShellState extends State<BackofficeAppShell> {
  late final BackofficeController _backofficeController;

  @override
  void initState() {
    super.initState();

    final orderRepository = context.read<OrderRepository>();

    _backofficeController = BackofficeController(
      orderRepository: orderRepository,
    )..loadDashboard();
  }

  @override
  void dispose() {
    _backofficeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BackofficeController>.value(
      value: _backofficeController,
      child: const BackofficePage(isActive: true),
    );
  }
}
