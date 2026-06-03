import '../sync/menu_sync_service.dart';
import '../sync/order_mirror_sync_service.dart';
import 'host_api_server.dart';
import 'host_client.dart';
import 'manual_host_config.dart';

class NetworkSession {
  const NetworkSession({
    required this.mode,
    this.hostConfig,
    this.server,
    this.hostClient,
    this.menuSyncService,
    this.orderMirrorSyncService,
  });

  final String mode;
  final ManualHostConfig? hostConfig;
  final HostApiServer? server;
  final HostClient? hostClient;
  final MenuSyncService? menuSyncService;
  final OrderMirrorSyncService? orderMirrorSyncService;

  bool get isHost => mode == 'host';
  bool get isClient => mode == 'client';
}
