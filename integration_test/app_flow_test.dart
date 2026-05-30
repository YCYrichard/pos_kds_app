import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_kds_app/app.dart';
import 'package:pos_kds_app/app_bootstrap_context.dart';
import 'package:pos_kds_app/app_role.dart';
import 'package:pos_kds_app/data/db/app_database.dart';
import 'package:pos_kds_app/data/models/menu_item.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';
import 'package:pos_kds_app/device_config.dart';
import 'package:pos_kds_app/network/network_session.dart';
import 'package:pos_kds_app/sync_mode.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'combined app boots with debug session metadata',
    (WidgetTester tester) async {
      // AppDatabase.database 是 Future<Database>，
      // 這裡用 lambda 包成函式，型別就符合 MenuRepository 的 DbGetter 了。
      final menuRepository = MenuRepository(
        databaseGetter: () => AppDatabase.database,
        deviceId: 'combined-device-01',
      );

      await menuRepository.insertIgnore(
        const MenuItem(itemCode: '1', itemName: '雞排', price: 80),
      );

      final orderRepository = OrderRepository();

      final bootstrapContext = AppBootstrapContext(
        deviceConfig: const DeviceConfig(
          deviceId: 'combined-device-01',
          deviceName: 'Combined Admin Terminal',
          installedRole: AppRole.combined,
          allowedRuntimeRoles: <AppRole>{
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
        orderRepository: orderRepository,
        resolutionReason: 'Test bootstrap context.',
        // 這三個是你現在 AppBootstrapContext 新增的 required 參數
        databaseStrategyName: 'test',
        databaseStrategyNotes: 'app_flow_test',
        networkSession: const NetworkSession(mode: 'local'),
        hostDeviceId: null,
        takeoverSourceRole: null,
      );

      await tester.pumpWidget(
        MultiProvider(
          // 這裡不需要 <SingleChildWidget>，直接讓 Dart 自己推斷
          providers: [
            Provider<DeviceConfig>.value(value: bootstrapContext.deviceConfig),
            Provider<MenuRepository>.value(
              value: bootstrapContext.menuRepository,
            ),
            Provider<OrderRepository>.value(
              value: bootstrapContext.orderRepository,
            ),
            Provider<AppBootstrapContext>.value(value: bootstrapContext),
          ],
          child: const PosKdsApp(role: AppRole.combined),
        ),
      );

      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Debug Session'), findsOneWidget);
      expect(find.textContaining('Combined Admin Terminal'), findsOneWidget);
    },
  );
}
