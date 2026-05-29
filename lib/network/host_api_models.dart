import 'dart:convert';

import 'package:pos_kds_app/data/models/menu_item.dart';
import 'package:pos_kds_app/data/models/order.dart';
import 'package:pos_kds_app/data/models/order_item.dart';
import 'package:pos_kds_app/data/repositories/order_repository.dart';

class ActiveOrderBundleDto {
  const ActiveOrderBundleDto({
    required this.order,
    required this.items,
  });

  final OrderEntity order;
  final List<OrderItemEntity> items;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'order': order.toMap(),
      'items': items.map((OrderItemEntity e) => e.toMap()).toList(),
    };
  }

  static ActiveOrderBundleDto fromJson(Map<String, dynamic> json) {
    return ActiveOrderBundleDto(
      order: OrderEntity.fromMap(
        Map<String, Object?>.from(json['order'] as Map),
      ),
      items: (json['items'] as List<dynamic>)
          .map(
            (dynamic e) => OrderItemEntity.fromMap(
              Map<String, Object?>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

String encodeMenuList(List<MenuItem> items) {
  return jsonEncode(
    items.map((MenuItem e) => e.toMap()).toList(),
  );
}

List<MenuItem> decodeMenuList(String raw) {
  final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map(
        (dynamic e) => MenuItem.fromMap(
          Map<String, Object?>.from(e as Map),
        ),
      )
      .toList();
}

String encodeActiveBundles(List<OrderBundle> bundles) {
  return jsonEncode(
    bundles
        .map(
          (OrderBundle e) => ActiveOrderBundleDto(
            order: e.order,
            items: e.items,
          ).toJson(),
        )
        .toList(),
  );
}

List<OrderBundle> decodeActiveBundles(String raw) {
  final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
  return decoded.map((dynamic e) {
    final dto = ActiveOrderBundleDto.fromJson(
      Map<String, dynamic>.from(e as Map),
    );
    return OrderBundle(order: dto.order, items: dto.items);
  }).toList();
}
