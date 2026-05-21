import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'features/backoffice/backoffice_controller.dart';
import 'features/backoffice/backoffice_page.dart';
import 'features/frontdesk/frontdesk_controller.dart';
import 'features/frontdesk/frontdesk_page.dart';
import 'features/kitchen/kitchen_controller.dart';
import 'features/kitchen/kitchen_page.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/l10n.dart';

class PosKdsApp extends StatelessWidget {
  const PosKdsApp({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appTitle(role),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC97D60),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: _AppRoot(role: role),
    );
  }

  String _appTitle(AppRole role) {
    switch (role) {
      case AppRole.frontdesk:
        return 'POS Frontdesk App';
      case AppRole.kitchen:
        return 'POS Kitchen App';
      case AppRole.backoffice:
        return 'POS Backoffice App';
      case AppRole.combined:
        return 'POS KDS App';
    }
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case AppRole.frontdesk:
        return const _FrontdeskAppShell();
      case AppRole.kitchen:
        return const _KitchenAppShell();
      case AppRole.backoffice:
        return const _BackofficeAppShell();
      case AppRole.combined:
        return const _CombinedAppShell();
    }
  }
}

class _CombinedAppShell extends StatefulWidget {
  const _CombinedAppShell();

  @override
  State<_CombinedAppShell> createState() => _CombinedAppShellState();
}

class _CombinedAppShellState extends State<_CombinedAppShell> {
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
    )..loadDashboard();
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

class _FrontdeskAppShell extends StatefulWidget {
  const _FrontdeskAppShell();

  @override
  State<_FrontdeskAppShell> createState() => _FrontdeskAppShellState();
}

class _FrontdeskAppShellState extends State<_FrontdeskAppShell> {
  late final FrontdeskController _frontdeskController;

  @override
  void initState() {
    super.initState();

    final menuRepository = context.read<MenuRepository>();
    final orderRepository = context.read<OrderRepository>();

    _frontdeskController = FrontdeskController(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
    );
  }

  @override
  void dispose() {
    _frontdeskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FrontdeskController>.value(
      value: _frontdeskController,
      child: const FrontdeskPage(),
    );
  }
}

class _KitchenAppShell extends StatefulWidget {
  const _KitchenAppShell();

  @override
  State<_KitchenAppShell> createState() => _KitchenAppShellState();
}

class _KitchenAppShellState extends State<_KitchenAppShell> {
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

class _BackofficeAppShell extends StatefulWidget {
  const _BackofficeAppShell();

  @override
  State<_BackofficeAppShell> createState() => _BackofficeAppShellState();
}

class _BackofficeAppShellState extends State<_BackofficeAppShell> {
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
