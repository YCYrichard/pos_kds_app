import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';

Future<void> bootstrapApp(AppRole role) async {
  WidgetsFlutterBinding.ensureInitialized();

  final context = await _createBootstrapContext();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppBootstrapContext>.value(value: context),
        Provider<MenuRepository>.value(value: context.menuRepository),
        Provider<OrderRepository>.value(value: context.orderRepository),
      ],
      child: PosKdsApp(role: role),
    ),
  );
}

Future<AppBootstrapContext> _createBootstrapContext() async {
  final menuRepository = MenuRepository();
  await menuRepository.seedDefaultMenu();

  final orderRepository = OrderRepository();

  return AppBootstrapContext(
    menuRepository: menuRepository,
    orderRepository: orderRepository,
  );
}
