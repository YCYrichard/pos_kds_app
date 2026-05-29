import 'package:pos_kds_app/data/repositories/order_repository.dart';

import 'host_api_models.dart';
import 'host_client.dart';

class NetworkOrderRepository {
  NetworkOrderRepository({
    required HostClient hostClient,
  }) : _hostClient = hostClient;

  final HostClient _hostClient;

  Future<List<OrderBundle>> getActiveOrderBundles() async {
    final String raw = await _hostClient.getActiveOrdersRaw();
    return decodeActiveBundles(raw);
  }

  Future<void> completeOrderItem(int itemId) {
    return _hostClient.completeOrderItem(itemId);
  }
}
