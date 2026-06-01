// lib/sync/menu_sync_service.dart

import 'dart:convert';

import 'package:pos_kds_app/data/models/menu_item.dart';
import 'package:pos_kds_app/data/repositories/menu_repository.dart';
import 'package:pos_kds_app/network/host_client.dart';

/// 抽象化同步狀態存取，之後可以換成 DB 實作
abstract class SyncStateStore {
  Future<String?> getLastAppliedMenuHlc();
  Future<void> setLastAppliedMenuHlc(String hlc);
}

/// 目前先用記憶體實作，App 重啟就會重置
class InMemorySyncStateStore implements SyncStateStore {
  String? _lastMenuHlc;

  @override
  Future<String?> getLastAppliedMenuHlc() async => _lastMenuHlc;

  @override
  Future<void> setLastAppliedMenuHlc(String hlc) async {
    _lastMenuHlc = hlc;
  }
}

/// Client 端菜單同步：從 host 拉 menuItem 相關 sync events，套用到本地 menu_items
class MenuSyncService {
  MenuSyncService({
    required this.localMenuRepository,
    required this.hostClient,
    required this.syncStateStore,
  });

  final MenuRepository localMenuRepository;
  final HostClient hostClient;
  final SyncStateStore syncStateStore;

  /// 單次同步流程：pull → filter → apply → update last HLC
  Future<void> syncOnce() async {
    // 1. 讀取目前已套用的最後 HLC（exclusive）
    final String? lastHlc = await syncStateStore.getLastAppliedMenuHlc();

    // 2. 從 host 拉事件
    final events = await hostClient.getSyncEventsSince(lastHlc);

    if (events.isEmpty) {
      return;
    }

    String? maxHlc;

    for (final event in events) {
      final String? entityType =
          (event['entity_type'] ?? event['entityType']) as String?;
      final String? action = event['action'] as String?;
      final String? payloadJson =
          (event['payload_json'] ?? event['payloadJson']) as String?;
      final String? hlc = event['hlc'] as String?;

      if (entityType != 'menuItem' || action != 'menuUpsert') {
        continue;
      }
      if (payloadJson == null || hlc == null) {
        continue;
      }

      // 3. decode payload 建立 MenuItem
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      final MenuItem item = _menuItemFromPayload(decoded);

      // 4. 套用到本地 menu_items（upsert）
      await localMenuRepository.upsertMenuItem(item);

      // 5. 更新本輪最大 HLC
      if (maxHlc == null || hlc.compareTo(maxHlc) > 0) {
        maxHlc = hlc;
      }
    }

    if (maxHlc != null) {
      await syncStateStore.setLastAppliedMenuHlc(maxHlc);
    }
  }

  /// 這裡的 mapping 盡量跟 MenuRepository._fromJson 保持一致
  MenuItem _menuItemFromPayload(Map<String, dynamic> map) {
    final String code = (map['item_code'] ?? map['itemCode']) as String? ?? '';
    final String name = (map['item_name'] ?? map['itemName']) as String? ?? '';
    final int price = (map['price'] as num?)?.toInt() ?? 0;

    final dynamic activeRaw = map['is_active'] ?? map['isActive'];
    bool isActive;
    if (activeRaw is bool) {
      isActive = activeRaw;
    } else if (activeRaw is num) {
      isActive = activeRaw.toInt() != 0;
    } else {
      isActive = true;
    }

    return MenuItem(
      itemCode: code,
      itemName: name,
      price: price,
      isActive: isActive,
    );
  }
}
