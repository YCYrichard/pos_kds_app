import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_bootstrap.dart';
import '../../app_role.dart';
import '../../device_persistence/device_config_store.dart';
import '../../device_persistence/device_record.dart';
import '../../device_persistence/store_bootstrap_store.dart';
import '../../network/bootstrap_service.dart';
import '../../network/host_discovery_service.dart';
import '../../network/local_network_info.dart';
import 'bootstrap_controller.dart';
import 'bootstrap_page.dart';

class BootstrapGateApp extends StatelessWidget {
  const BootstrapGateApp({
    super.key,
    required this.installedRole,
    required this.deviceRecord,
    required this.deviceConfigStore,
    required this.storeBootstrapStore,
  });

  final AppRole installedRole;
  final DeviceRecord deviceRecord;
  final DeviceConfigStore deviceConfigStore;
  final StoreBootstrapStore storeBootstrapStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeviceConfigStore>.value(value: deviceConfigStore),
        Provider<StoreBootstrapStore>.value(value: storeBootstrapStore),
        Provider<BootstrapService>(
          create: (_) => BootstrapService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<HostDiscoveryService>(
          create: (_) => HostDiscoveryService(port: 8787),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<LocalNetworkInfo>(
          create: (_) => LocalNetworkInfo(),
        ),
        ChangeNotifierProvider<BootstrapController>(
          create: (context) => BootstrapController(
            installedRole: installedRole,
            deviceRecord: deviceRecord,
            deviceConfigStore: deviceConfigStore,
            storeBootstrapStore: storeBootstrapStore,
            bootstrapService: context.read<BootstrapService>(),
            hostDiscoveryService: context.read<HostDiscoveryService>(),
            localNetworkInfo: context.read<LocalNetworkInfo>(),
            onCompleted: () async {
              await bootstrapApp(installedRole);
            },
          )..initialize(),
        ),
      ],
      child: const _BootstrapGateMaterialApp(),
    );
  }
}

class _BootstrapGateMaterialApp extends StatelessWidget {
  const _BootstrapGateMaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BootstrapPage(),
    );
  }
}
