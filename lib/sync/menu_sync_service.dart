import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pos_kds_app/data/models/menu_item.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/network/host_client.dart';

abstract class SyncStateStore {
  Future<String?> getLastAppliedMenuHlc();
  Future<void> setLastAppliedMenuHlc(String hlc);
}

class InMemorySyncStateStore implements SyncStateStore {
  String? _lastMenuHlc;

  @override
  Future<String?> getLastAppliedMenuHlc() async => _lastMenuHlc;

  @override
  Future<void> setLastAppliedMenuHlc(String hlc) async {
    _lastMenuHlc = hlc;
  }
}

class MenuSyncService {
  MenuSyncService({
    required this.localMenuRepository,
    required this.hostClient,
    required this.syncStateStore,
  });

  final MenuRepository localMenuRepository;
  final HostClient hostClient;
  final SyncStateStore syncStateStore;

  Future<void> syncOnce() async {
    final String? lastHlc = await syncStateStore.getLastAppliedMenuHlc();
    final List<Map<String, dynamic>> events =
        await hostClient.getSyncEventsSince(lastHlc);

    if (events.isEmpty) {
      return;
    }

    String? maxHlc;

    for (final Map<String, dynamic> event in events) {
      final String? entityType = _asString(event['entity_type']);
      final String? action = _asString(event['action']);
      final String? payloadJson = _asString(event['payload_json']);
      final String? hlc = _asString(event['hlc']);

      if (entityType != 'menuItem' || action != 'menuUpsert') {
        continue;
      }

      if (payloadJson == null || payloadJson.isEmpty || hlc == null) {
        debugPrint(
          'MenuSyncService: skip invalid event, missing payload_json or hlc: $event',
        );
        continue;
      }

      final MenuItem? item = _tryParseMenuItemPayload(payloadJson);
      if (item == null) {
        debugPrint(
          'MenuSyncService: skip invalid menu payload_json: $payloadJson',
        );
        continue;
      }

      await localMenuRepository.upsertMenuItem(item);

      if (maxHlc == null || hlc.compareTo(maxHlc) > 0) {
        maxHlc = hlc;
      }
    }

    if (maxHlc != null) {
      await syncStateStore.setLastAppliedMenuHlc(maxHlc);
    }
  }

  MenuItem? _tryParseMenuItemPayload(String payloadJson) {
    final dynamic decoded = jsonDecode(payloadJson);

    if (decoded is! Map) {
      return null;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);

    final String? itemCode = _asString(map['itemCode'] ?? map['item_code']);
    final String? itemName = _asString(map['itemName'] ?? map['item_name']);
    final int? price = _asInt(map['price']);
    final bool isActive = _asBool(map['isActive'] ?? map['is_active']) ?? true;

    if (itemCode == null || itemCode.isEmpty) {
      return null;
    }
    if (itemName == null || itemName.isEmpty) {
      return null;
    }
    if (price == null) {
      return null;
    }

    return MenuItem(
      itemCode: itemCode,
      itemName: itemName,
      price: price,
      isActive: isActive,
    );
  }

  String? _asString(Object? value) {
    if (value is String) {
      return value;
    }
    return null;
  }

  int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  bool? _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0;
    }
    return null;
  }
}
