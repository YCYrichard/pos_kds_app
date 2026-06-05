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
  SyncMode get resolvedSyncMode => _resolvedSyncMode;
  String get appInstanceId => _appInstanceId;
  String get resolutionReason => _resolutionReason;
  bool get canOverrideRole => _canOverrideRole;
  String? get hostDeviceId => _hostDeviceId;
  AppRole? get takeoverSourceRole => _takeoverSourceRole;

  bool get isBoundToRemoteHost {
    final normalizedHost = _hostDeviceId?.trim();
    if (normalizedHost == null || normalizedHost.isEmpty) {
      return false;
    }
    return normalizedHost != _deviceId;
  }

  bool get isBoundToSelf {
    final normalizedHost = _hostDeviceId?.trim();
    if (normalizedHost == null || normalizedHost.isEmpty) {
      return false;
    }
    return normalizedHost == _deviceId;
  }

  bool get isClientMode => _resolvedSyncMode == SyncMode.client;
  bool get isHostMode => _resolvedSyncMode == SyncMode.host;
  bool get isStandaloneMode => _resolvedSyncMode == SyncMode.standalone;

  bool get canUseFrontdesk => !isBoundToRemoteHost;
  bool get canUseKitchen => true;
  bool get canUseBackoffice => true;
  bool get canUseCombined => !isBoundToRemoteHost;

  void updatePersistentIdentity({
    required String deviceName,
    required String? hostDeviceId,
  }) {
    _deviceName = deviceName.trim();
    _hostDeviceId = _normalizeNullable(hostDeviceId);
    _resolvedSyncMode = _resolveEffectiveSyncMode(
      deviceId: _deviceId,
      runtimeRole: _runtimeRole,
      hostDeviceId: _hostDeviceId,
      fallback: _resolvedSyncMode,
    );
    notifyListeners();
  }

  void updateRuntimeRole(AppRole runtimeRole) {
    _runtimeRole = runtimeRole;
    _resolvedSyncMode = _resolveEffectiveSyncMode(
      deviceId: _deviceId,
      runtimeRole: _runtimeRole,
      hostDeviceId: _hostDeviceId,
      fallback: _resolvedSyncMode,
    );
    _resolutionReason = 'manual override to ${runtimeRole.name}';
    notifyListeners();
  }

  void updateBootstrapContext({
    required AppBootstrapContext bootstrapContext,
  }) {
    _deviceId = bootstrapContext.deviceConfig.deviceId;
    _deviceName = bootstrapContext.deviceConfig.deviceName;
    _installedRole = bootstrapContext.deviceConfig.installedRole;
    _runtimeRole = bootstrapContext.runtimeRole;
    _resolvedSyncMode = bootstrapContext.resolvedSyncMode;
    _appInstanceId = bootstrapContext.appInstanceId;
    _resolutionReason = bootstrapContext.resolutionReason;
    _canOverrideRole = bootstrapContext.canOverrideRole;
    _hostDeviceId = bootstrapContext.hostDeviceId;
    _takeoverSourceRole = bootstrapContext.takeoverSourceRole;
    notifyListeners();
  }

  SyncMode _resolveEffectiveSyncMode({
    required String deviceId,
    required AppRole runtimeRole,
    required String? hostDeviceId,
    required SyncMode fallback,
  }) {
    final String normalizedHost = hostDeviceId?.trim() ?? '';
    final bool hasHostBinding = normalizedHost.isNotEmpty;
    final bool boundToRemoteHost = hasHostBinding && normalizedHost != deviceId;

    if (boundToRemoteHost) {
      return SyncMode.client;
    }

    if (runtimeRole == AppRole.combined || runtimeRole == AppRole.frontdesk) {
      return SyncMode.host;
    }

    if (fallback == SyncMode.client && !boundToRemoteHost) {
      return SyncMode.standalone;
    }

    return fallback;
  }

  String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
