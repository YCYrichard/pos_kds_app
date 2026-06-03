import 'package:pos_kds_app/data/repositories/order_repository.dart';
import 'package:pos_kds_app/network/host_client.dart';

class OrderMirrorSyncService {
  OrderMirrorSyncService({
    required this.localOrderRepository,
    required this.hostClient,
  });

  final OrderRepository localOrderRepository;
  final HostClient hostClient;

  Future<void> syncActiveOrdersOnce() async {
    final List<OrderBundle> bundles = await hostClient.getActiveOrderBundles();
    await localOrderRepository.replaceActiveOrderBundles(bundles);
  }

  Future<void> completeOrderItemAndRefresh(int itemId) async {
    await hostClient.completeOrderItem(itemId);
    await syncActiveOrdersOnce();
  }
}
