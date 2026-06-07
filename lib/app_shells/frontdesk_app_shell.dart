import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_bootstrap_context.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/order_repository.dart';
import '../features/frontdesk/frontdesk_controller.dart';
import '../features/frontdesk/frontdesk_page.dart';

class FrontdeskAppShell extends StatefulWidget {
  const FrontdeskAppShell({super.key});

  @override
  State<FrontdeskAppShell> createState() => _FrontdeskAppShellState();
}

class _FrontdeskAppShellState extends State<FrontdeskAppShell> {
  late final FrontdeskController frontdeskController;

  @override
  void initState() {
    super.initState();
    final menuRepository = context.read<MenuRepository>();
    final orderRepository = context.read<OrderRepository>();
    final bootstrapContext = context.read<AppBootstrapContext>();

    frontdeskController = FrontdeskController(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
      networkSession: bootstrapContext.networkSession,
    );
  }

  @override
  void dispose() {
    frontdeskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FrontdeskController>.value(
      value: frontdeskController,
      child: const FrontdeskPage(),
    );
  }
}
