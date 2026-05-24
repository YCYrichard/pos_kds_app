import 'package:flutter/foundation.dart';

import 'app_bootstrap_context.dart';
import 'app_role.dart';
import 'sync_mode.dart';

class AppSessionState extends ChangeNotifier {
  AppSessionState({
    required AppBootstrapContext bootstrapContext,
  })  : _deviceId = bootstrapContext.deviceConfig.deviceId,
        _deviceName = bootstrapContext.deviceConfig.deviceName,
        _installedRole = bootstrapContext.deviceConfig.installedRole,
        _runtimeRole = bootstrapContext.runtimeRole,
        _baseSyncMode = _deriveBaseSyncMode(
          bootstrapContext: bootstrapContext,
        ),
        _resolvedSyncMode = bootstrapContext.resolvedSyncMode,
        _appInstanceId = bootstrapContext.appInstanceId,
        _resolutionReason = bootstrapContext.resolutionReason,
        _canOverrideRole = bootstrapContext.canOverrideRole,
        _hostDeviceId = bootstrapContext.hostDeviceId,
        _takeoverSourceRole = bootstrapContext.takeoverSourceRole;

  String _deviceId;
  String _deviceName;
  AppRole _installedRole;
  AppRole _runtimeRole;
  SyncMode _baseSyncMode;
  SyncMode _resolvedSyncMode;
  String _appInstanceId;
  String _resolutionReason;
  bool _canOverrideRole;
  String? _hostDeviceId;
  AppRole? _takeoverSourceRole;

  String get deviceId => _deviceId;
  String get deviceName => _deviceName;
  AppRole get installedRole => _installedRole;
  AppRole get runtimeRole => _runtimeRole;
  SyncMode get baseSyncMode => _baseSyncMode;
  SyncMode get resolvedSyncMode => _resolvedSyncMode;
  String get appInstanceId => _appInstanceId;
  String get resolutionReason => _resolutionReason;
  bool get canOverrideRole => _canOverrideRole;
  String? get hostDeviceId => _hostDeviceId;
  AppRole? get takeoverSourceRole => _takeoverSourceRole;

  void updatePersistentIdentity({
    required String deviceName,
    required String? hostDeviceId,
  }) {
    _deviceName = deviceName.trim();
    _hostDeviceId = _normalizeNullable(hostDeviceId);
    _resolvedSyncMode = _resolveEffectiveSyncMode(
      runtimeRole: _runtimeRole,
      baseSyncMode: _baseSyncMode,
      hostDeviceId: _hostDeviceId,
    );
    notifyListeners();
  }

  static SyncMode _deriveBaseSyncMode({
    required AppBootstrapContext bootstrapContext,
  }) {
    if ((bootstrapContext.hostDeviceId ?? '').trim().isNotEmpty) {
      return bootstrapContext.runtimeRole == AppRole.combined
          ? SyncMode.host
          : bootstrapContext.deviceConfig.defaultSyncMode;
    }

    if (bootstrapContext.runtimeRole == AppRole.combined &&
        bootstrapContext.resolvedSyncMode == SyncMode.client) {
      return SyncMode.host;
    }

    return bootstrapContext.resolvedSyncMode;
  }

  static SyncMode _resolveEffectiveSyncMode({
    required AppRole runtimeRole,
    required SyncMode baseSyncMode,
    required String? hostDeviceId,
  }) {
    final normalizedHost = hostDeviceId?.trim() ?? '';
    if (normalizedHost.isNotEmpty) {
      return SyncMode.client;
    }

    if (runtimeRole == AppRole.combined && baseSyncMode == SyncMode.client) {
      return SyncMode.host;
    }

    return baseSyncMode;
  }

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
