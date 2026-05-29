import 'host_api_server.dart';
import 'manual_host_config.dart';

class NetworkSession {
  const NetworkSession({
    required this.mode,
    this.hostConfig,
    this.server,
  });

  final String mode;
  final ManualHostConfig? hostConfig;
  final HostApiServer? server;

  bool get isHost => mode == 'host';
  bool get isClient => mode == 'client';
}
