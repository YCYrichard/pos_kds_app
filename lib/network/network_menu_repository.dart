import 'package:pos_kds_app/data/models/menu_item.dart';

import 'host_api_models.dart';
import 'host_client.dart';

class NetworkMenuRepository {
  NetworkMenuRepository({
    required HostClient hostClient,
  }) : _hostClient = hostClient;

  final HostClient _hostClient;

  Future<List<MenuItem>> getAllActive() async {
    final String raw = await _hostClient.getMenuRaw();
    return decodeMenuList(raw);
  }
}
