import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final menuRepository = MenuRepository();
  await menuRepository.seedDefaultMenu();

  runApp(
    MultiProvider(
      providers: [
        Provider<MenuRepository>.value(value: menuRepository),
        Provider<OrderRepository>(create: (_) => OrderRepository()),
      ],
      child: const PosKdsApp(),
    ),
  );
}
