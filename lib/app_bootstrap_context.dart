import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';

class AppBootstrapContext {
  const AppBootstrapContext({
    required this.menuRepository,
    required this.orderRepository,
  });

  final MenuRepository menuRepository;
  final OrderRepository orderRepository;
}
