import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_kds_app/app.dart';
import 'package:pos_kds_app/app_bootstrap_context.dart';
import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';
import 'package:pos_kds_app/device_config.dart';
import 'package:pos_kds_app/sync_mode.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('combined app boots with debug session metadata', (tester) async {
    final menuRepository = MenuRepository();
    await menuRepository.seedDefaultMenu();

    final bootstrapContext = AppBootstrapContext(
      deviceConfig: const DeviceConfig(
        deviceId: 'combined-device-01',
        deviceName: 'Combined Admin Terminal',
        installedRole: AppRole.combined,
        allowedRuntimeRoles: {
          AppRole.combined,
          AppRole.backoffice,
          AppRole.frontdesk,
          AppRole.kitchen,
        },
        defaultSyncMode: SyncMode.host,
        allowRoleOverride: true,
      ),
      runtimeRole: AppRole.combined,
      resolvedSyncMode: SyncMode.host,
      appInstanceId: 'combined-device-01_combined_test',
      startedAt: DateTime(2026, 5, 23),
      menuRepository: menuRepository,
      orderRepository: OrderRepository(),
      resolutionReason: 'Test bootstrap context.',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DeviceConfig>.value(value: bootstrapContext.deviceConfig),
          Provider<MenuRepository>.value(
              value: bootstrapContext.menuRepository),
          Provider<OrderRepository>.value(
              value: bootstrapContext.orderRepository),
          Provider<AppBootstrapContext>.value(value: bootstrapContext),
        ],
        child: const PosKdsApp(role: AppRole.combined),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Frontdesk'), findsWidgets);
    expect(find.text('Kitchen'), findsWidgets);
    expect(find.text('Backoffice'), findsWidgets);

    expect(
      find.textContaining('device=Combined Admin Terminal'),
      findsOneWidget,
    );
    expect(
      find.textContaining('runtimeRole=combined'),
      findsOneWidget,
    );
    expect(
      find.textContaining('syncMode=host'),
      findsOneWidget,
    );
  });
}
