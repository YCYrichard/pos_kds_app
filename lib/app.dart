import 'package:flutter/material.dart';

import 'features/backoffice/backoffice_page.dart';
import 'features/frontdesk/frontdesk_page.dart';
import 'features/kitchen/kitchen_page.dart';

class PosKdsApp extends StatelessWidget {
  const PosKdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS KDS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC97D60),
        ),
        useMaterial3: true,
      ),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  final _pages = const [
    FrontdeskPage(),
    KitchenPage(),
    BackofficePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Frontdesk',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Backoffice',
          ),
        ],
      ),
    );
  }
}
