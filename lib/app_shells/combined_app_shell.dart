import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/menu_repository.dart';
import '../data/repositories/order_repository.dart';
import '../features/backoffice/backoffice_controller.dart';
import '../features/backoffice/backoffice_page.dart';
import '../features/frontdesk/frontdesk_controller.dart';
import '../features/frontdesk/frontdesk_page.dart';
import '../features/kitchen/kitchen_controller.dart';
import '../features/kitchen/kitchen_page.dart';
import '../l10n/l10n.dart';

class CombinedAppShell extends StatefulWidget {
  const CombinedAppShell({super.key});

  @override
  State<CombinedAppShell> createState() => _CombinedAppShellState();
}

class _CombinedAppShellState extends State<CombinedAppShell> {
  late final FrontdeskController _frontdeskController;
  late final KitchenController _kitchenController;
  late final BackofficeController _backofficeController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final menuRepository = context.read<MenuRepository>();
    final orderRepository = context.read<OrderRepository>();

    _frontdeskController = FrontdeskController(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
    );

    _kitchenController = KitchenController(
      orderRepository: orderRepository,
    )..loadOrders();

    _backofficeController = BackofficeController(
      orderRepository: orderRepository,
      menuRepository: menuRepository,
    )
      ..loadDashboard()
      ..loadMenuItems();
  }

  @override
  void dispose() {
    _frontdeskController.dispose();
    _kitchenController.dispose();
    _backofficeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pages = [
      ChangeNotifierProvider<FrontdeskController>.value(
        value: _frontdeskController,
        child: const FrontdeskPage(),
      ),
      ChangeNotifierProvider<KitchenController>.value(
        value: _kitchenController,
        child: KitchenPage(isActive: _currentIndex == 1),
      ),
      ChangeNotifierProvider<BackofficeController>.value(
        value: _backofficeController,
        child: BackofficePage(isActive: _currentIndex == 2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: l10n.tabFrontdesk,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: l10n.tabKitchen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.tabBackoffice,
          ),
        ],
      ),
    );
  }
}
